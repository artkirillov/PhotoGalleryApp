//
//  GalleryViewController.swift
//  Look At This
//
//  Created by Artem Kirillov on 07/07/2019.
//

import UIKit

protocol PhotoService {
    var count: Int { get }
    func fetchNextPage(completion: @escaping (Error?) -> Void)
    func photoInteractor(forPhotoWithIndex: Int) -> PhotoInteractor?
}

class GalleryViewController: UIViewController {
    
    // MARK: - Public Properties
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    var selectedItemFrame: CGRect?
    var selectedImage: UIImage?
    
    // MARK: - Constructors
    
    init(photoService: PhotoService) {
        self.photoService = photoService
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    override func loadView() {
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Look at pictures!"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        getData()
        
        collectionView.register(
            GallleryViewCell.self,
            forCellWithReuseIdentifier: GallleryViewCell.reuseIdentifier
        )
        
        collectionView.alwaysBounceVertical = true
        collectionView.prefetchDataSource = self
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Private Properties
    
    private let photoService: PhotoService
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: GalleryViewLayout()
    )
    
}

// MARK: - UICollectionViewDataSourcePrefetching

extension GalleryViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let lastIndex = indexPaths.last?.item, lastIndex == photoService.count - 1 else { return }
        getData()
    }
    
}

// MARK: - UICollectionViewDataSource

extension GalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoService.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GallleryViewCell.reuseIdentifier, for: indexPath) as? GallleryViewCell, let photoInteractor = photoService.photoInteractor(forPhotoWithIndex: indexPath.item)
        else {
            assert(false, "Cell for gallery view must be of type GallleryViewCell with valid photo interactor")
            return UICollectionViewCell()
        }
        
        cell.configure(with: photoInteractor)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension GalleryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateSelectedFrameAndImage(indexPath: indexPath)
        
        let photoViewController = PhotoViewController(currentIndex: indexPath.item, photoService: photoService)
        photoViewController.delegate = self
        navigationController?.pushViewController(photoViewController, animated: true)
    }
    
}

// MARK: - PhotoViewControllerDelegate

extension GalleryViewController: PhotoViewControllerDelegate {
    
    func photoViewController(_ controller: PhotoViewController, didChangeCurrentIndex index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(
            at: indexPath,
            at: .centeredVertically,
            animated: false
        )
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? GallleryViewCell else { return }
        selectedItemFrame = CGRect(
            x: cell.frame.minX,
            y: cell.frame.minY + (navigationController?.navigationBar.frame.maxY ?? 0),
            width: cell.frame.width, height: cell.frame.height)
        selectedImage = cell.image
    }
    
}

private extension GalleryViewController {
    
    // MARK: - Private Methods
    
    func updateSelectedFrameAndImage(indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GallleryViewCell else { return }
        selectedItemFrame = collectionView.convert(cell.frame, to: view.window)
        selectedImage = cell.image
    }
    
    func getData() {
        photoService.fetchNextPage { [weak self] error in
            if let error = error {
                self?.present(UIAlertController.standard(error: error), animated: true, completion: nil)
            } else {
                self?.collectionView.reloadData()
            }
        }
    }
    
}
