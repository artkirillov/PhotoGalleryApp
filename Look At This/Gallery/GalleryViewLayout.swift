//
//  GalleryViewLayout.swift
//  Look At This
//
//  Created by Artem Kirillov on 07/07/2019.
//

import UIKit

class GalleryViewLayout: UICollectionViewLayout {
    
    // MARK: - Public Properties
    
    override var collectionViewContentSize: CGSize {
        return contentBounds.size
    }
    
    // MARK: - Public Methods
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView, collectionView.numberOfSections == 1 else {
            return assert(false, "Gallery view layout needs one section in collection view")
        }
        
        cachedAttributes.removeAll()
        contentBounds = CGRect(origin: .zero, size: collectionView.bounds.size)
        
        let count = collectionView.numberOfItems(inSection: 0)
        
        guard count > 0 else { return }
        
        let cvWidth = collectionView.bounds.size.width
        let columnWidth = ceil(cvWidth / CGFloat(Static.numberOfColumns))
        
        var xOffsets = [CGFloat]()
        for column in 0..<Static.numberOfColumns { xOffsets.append(CGFloat(column) * columnWidth) }
        
        var column = 0
        var yOffsets = [CGFloat](repeating: 0.0, count: Static.numberOfColumns)
        
        let photoHeight: (Int) -> CGFloat = { item in
            switch (item % 4) {
            case 0:  return ceil(columnWidth * Static.portraitRatio)
            case 1:  return ceil(columnWidth * Static.albumRatio)
            default:  return columnWidth
            }
        }
        
        let addAttributes: (Int, CGFloat, Int) -> Void = { item, height, column in
            let insets = UIEdgeInsets(
                top: item < Static.numberOfColumns ? 0 : Static.cellPadding,
                left: column == 0 ? 0 : Static.cellPadding,
                bottom: Static.cellPadding,
                right: column == Static.numberOfColumns - 1 ? 0 : Static.cellPadding
            )
            let frame = CGRect(x: xOffsets[column], y: yOffsets[column], width: columnWidth, height: height)
            let insetFrame = frame.inset(by: insets)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: item, section: 0))
            attributes.frame = insetFrame
            self.cachedAttributes.append(attributes)
            
            self.contentBounds.size.height = max(self.contentBounds.height, frame.maxY)
            yOffsets[column] = yOffsets[column] + height
        }
        
        for item in 0..<count {
            let nextColumn = column < (Static.numberOfColumns - 1) ? (column + 1) : 0
            let height: CGFloat
            
            height = photoHeight(item) + 2 * Static.cellPadding
            addAttributes(item, height, column)
            
            if yOffsets[nextColumn] < yOffsets[column] { column = nextColumn }
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.item < cachedAttributes.count else {
            assert(false, "Index exceeds array bounds")
            return nil
        }
        return cachedAttributes[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedAttributes.filter { $0.frame.intersects(rect) }
    }
    
    // MARK: - Private Properties
    
    private var contentBounds = CGRect.zero
    private var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
}

private extension GalleryViewLayout {
    
    // MARK: - Private Nested
    
    struct Static {
        static let numberOfColumns: Int = 2
        static let cellPadding: CGFloat = 4.0
        static let portraitRatio: CGFloat = 4 / 3
        static let albumRatio: CGFloat = 3 / 4
    }
    
}
