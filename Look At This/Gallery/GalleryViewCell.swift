//
//  GalleryViewCell.swift
//  Look At This
//
//  Created by Artem Kirillov on 07/07/2019.
//

import UIKit

protocol PhotoInteractor {
    var author: String { get }
    func downloadPhoto(completion: @escaping (UIImage?, Error?) -> Void)
    func cancelDownloading()
}

class GallleryViewCell: UICollectionViewCell {
    
    // MARK: - Public Nested
    
    static let reuseIdentifier = String(describing: GallleryViewCell.self)
    
    // MARK: - Public Properties
    
    var image: UIImage? {
        return imageView.image
    }
    
    // MARK: - Constructors
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupImageView()
        imageView.reset()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(with interactor: PhotoInteractor) {
        imageView.reset()
        interactor.downloadPhoto() { [weak self] image, error  in
            guard let slf = self, error == nil else { return }
            UIView.transition(
                with: slf.imageView,
                duration: 0.2,
                options: [.transitionCrossDissolve],
                animations: { slf.imageView.image = image },
                completion: nil
            )
        }
        
        self.interactor?.cancelDownloading()
        self.interactor = interactor
    }
    
    // MARK: - Private Properties
    
    private let imageView = UIImageView()
    private var interactor: PhotoInteractor?
    
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

