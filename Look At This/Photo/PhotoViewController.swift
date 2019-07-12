//
//  PhotoViewController.swift
//  Look At This
//
//  Created by Artem Kirillov on 07/07/2019.
//

import UIKit

protocol InteractiveTransitionDelegate: class {
    func interactiveTransitionDidChangeState(_ state: InteractiveTransitionState)
}

protocol PhotoViewControllerDelegate: class {
    func photoViewController(_ controller: PhotoViewController, didChangeCurrentIndex: Int)
}

class PhotoViewController: UIViewController {
    
    // MARK: - Public Properties
    
    override var prefersStatusBarHidden: Bool {
        return navigationBarHidden
    }
    
    private(set) var interactiveTransitionIsActive = false
    
    weak var delegate: PhotoViewControllerDelegate?
    weak var interactiveTransitionDelegate: InteractiveTransitionDelegate?
    
    private(set) var currentIndex: Int
    
    // MARK: - Constructors
    
    init(currentIndex: Int, photoService: PhotoService) {
        self.currentIndex = currentIndex
        self.photoService = photoService
        
        super.init(nibName: nil, bundle: nil)
        
        let author = photoService.photoInteractor(forPhotoWithIndex: currentIndex)?.author
        title = "Photo by \(author ?? "")"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView?.scrollToItem(
            at: IndexPath(item: currentIndex, section: 0),
            at: .centeredHorizontally,
            animated: false
        )
    }
    
    // MARK: - Private Properties
    
    private var navigationBarHidden = false
    private let photoService: PhotoService
    private var collectionView: UICollectionView?
    
}

// MARK: - UICollectionViewDataSource

extension PhotoViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoService.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoViewCell.reuseIdentifier, for: indexPath) as? PhotoViewCell, let photoInteractor = photoService.photoInteractor(forPhotoWithIndex: indexPath.item)
        else {
            assert(false, "Cell for gallery view must be of type PhotoViewCell with valid photo interactor")
            return UICollectionViewCell()
        }
        title = "Photo by \(photoInteractor.author)"
        cell.configure(with: photoInteractor)
        cell.delegate = self
        
        return cell
    }
}

// MARK: - PhotoViewCellDelegate

extension PhotoViewController: PhotoViewCellDelegate {
    
    func photoViewCellDidTap(_ cell: PhotoViewCell) {
        toggleNavigationBar()
    }
    
    func photoViewCell(_ cell: PhotoViewCell, didChangeTransitionState state: PhotoViewCell.TransitionState) {
        switch state {
        case .began:
            interactiveTransitionIsActive = true
            navigationController?.popViewController(animated: true)
            
        case .updating(let progress):
            interactiveTransitionDelegate?.interactiveTransitionDidChangeState(.updating(progress: progress))
            
        case .finishing:
            interactiveTransitionIsActive = false
            interactiveTransitionDelegate?.interactiveTransitionDidChangeState(.finishing)
            
        case .cancelling:
            interactiveTransitionIsActive = false
            interactiveTransitionDelegate?.interactiveTransitionDidChangeState(.cancelling)
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.bounds.width - Static.spacing,
                      height: collectionView.bounds.height)
    }
}

private extension PhotoViewController {
    
    // MARK: - Private Nested
    
    struct Static {
        static let spacing: CGFloat = 10.0
    }
    
    // MARK: - Private Methods
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Static.spacing
        layout.sectionInset = UIEdgeInsets(
            top: 0.0,
            left: Static.spacing / 2,
            bottom: 0.0,
            right: Static.spacing / 2
        )
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.register(
            PhotoViewCell.self,
            forCellWithReuseIdentifier: PhotoViewCell.reuseIdentifier
        )
        
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.allowsMultipleSelection = true
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -Static.spacing / 2),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: Static.spacing / 2),
            ])
        self.collectionView = collectionView
    }
    
    func toggleNavigationBar() {
        navigationBarHidden.toggle()
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.setNavigationBarHidden(navigationBarHidden, animated: false)
    }
    
}

// MARK: - UIScrollViewDelegate

extension PhotoViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        delegate?.photoViewController(self, didChangeCurrentIndex: currentIndex)
    }
    
}


