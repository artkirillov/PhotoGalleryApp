//
//  GalleryViewCell.swift
//  Look At This
//
//  Created by Artem Kirillov on 07/07/2019.
//

import UIKit

class GallleryViewCell: UICollectionViewCell {
    
    // MARK: - Public Nested
    
    static let reuseIdentifier = String(describing: GallleryViewCell.self)
    
    // MARK: - Constructors
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupImageView()
        backgroundColor = .darkGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(with image: UIImage) {
        imageView.image = image
    }
    
    // MARK: - Private Properties
    
    private let imageView = UIImageView()
    
}

private extension GallleryViewCell {
    
    // MARK: - Private Methods
    
    func setupImageView() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor),
            ])
    }
    
}

