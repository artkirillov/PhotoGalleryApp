//
//  GalleryViewController.swift
//  Look At This
//
//  Created by Artem Kirillov on 07/07/2019.
//

import UIKit

class GalleryViewController: UIViewController {
    
    // MARK: - Public Methods
    
    override func loadView() {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: GalleryViewLayout()
        )
        
        collectionView.register(
            GallleryViewCell.self,
            forCellWithReuseIdentifier: GallleryViewCell.reuseIdentifier
        )
        
        collectionView.alwaysBounceVertical = true
        collectionView.prefetchDataSource = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Look at this pictures!"
    }

}

// MARK: - UICollectionViewDataSourcePrefetching

extension GalleryViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        
    }
}

// MARK: - UICollectionViewDataSource

extension GalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GallleryViewCell.reuseIdentifier, for: indexPath) as? GallleryViewCell else {
                assert(false, "Cell for gallery view must be of type GallleryViewCell")
                return UICollectionViewCell()
        }
        cell.configure(with: UIImage(imageLiteralResourceName: indexPath.item % 2 == 0 ? "01" : "02"))
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension GalleryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoViewController = PhotoViewController()
        navigationController?.pushViewController(photoViewController, animated: true)
    }
    
}

