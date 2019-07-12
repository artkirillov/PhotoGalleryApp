//
//  PhotoViewCell.swift
//  Look At This
//
//  Created by Artem Kirillov on 07/07/2019.
//

import UIKit

protocol PhotoViewCellDelegate: class {
    func photoViewCellDidTap(_ cell: PhotoViewCell)
    func photoViewCell(_ cell: PhotoViewCell, didChangeTransitionState state: PhotoViewCell.TransitionState)
}

class PhotoViewCell: UICollectionViewCell {
    
    // MARK: - Public Nested
    
    enum TransitionState {
        case began
        case updating(progress: CGFloat)
        case finishing
        case cancelling
    }
    
    // MARK: - Public Properties
    
    weak var delegate: PhotoViewCellDelegate?
    
    static let reuseIdentifier = String(describing: PhotoViewCell.self)
    
    // MARK: - Constructors
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupScrollView()
        setupImageView()
        imageView.reset()
        
        _ = singleTapRecoginzer
        _ = doubleTapRecoginzer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(with interactor: PhotoInteractor) {
        imageView.reset()
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        interactor.downloadPhoto() { [weak self] image, error in
            guard let slf = self, error == nil else { return }
            UIView.transition(
                with: slf.imageView,
                duration: 0.2,
                options: [.transitionCrossDissolve],
                animations: {
                    slf.imageView.image = image
                    slf.setNeedsLayout()
                    slf.layoutIfNeeded()
            },
                completion: nil
            )
        }
        
        self.interactor?.cancelDownloading()
        self.interactor = interactor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = bounds
        
        guard let image = imageView.image,
            scrollView.zoomScale == scrollView.minimumZoomScale else { return }
        
        let imageSize = image.size
        let imageAspect = imageSize.height / imageSize.width
        let boundsAspect = bounds.height / bounds.width
        
        let newImageSize: CGSize
        if imageAspect > boundsAspect {
            newImageSize = CGSize(width: ceil(bounds.height / imageAspect), height: bounds.height)
        } else {
            newImageSize = CGSize(width: bounds.width, height: ceil(bounds.width * imageAspect))
        }

        imageView.frame = CGRect(origin: .zero, size: newImageSize)
        scrollView.contentSize = imageView.frame.size
        
        updateInsets()
    }
    
    // MARK: - Private Properties
    
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    
    private lazy var singleTapRecoginzer: UITapGestureRecognizer = {
        let recoginzer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        recoginzer.numberOfTapsRequired = 1
        addGestureRecognizer(recoginzer)
        return recoginzer
    }()
    
    private lazy var doubleTapRecoginzer: UITapGestureRecognizer = {
        let recoginzer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        recoginzer.numberOfTapsRequired = 2
        recoginzer.delegate = self
        addGestureRecognizer(recoginzer)
        return recoginzer
    }()
    
    private var interactor: PhotoInteractor?
    private var transitionIsUserDriving = false
    private var scrollViewIsZoomingFast = false
    
}

// MARK: - UIGestureRecognizerDelegate

extension PhotoViewCell: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return gestureRecognizer === doubleTapRecoginzer
    }
    
}

// MARK: - UIScrollViewDelegate

extension PhotoViewCell: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !scrollView.isZooming, !scrollView.isZoomBouncing, !scrollViewIsZoomingFast,
            scrollView.zoomScale == scrollView.minimumZoomScale
            else { return }
        
        let translation = currentVerticalTranslation()
        if scrollView.isDragging || scrollView.isDecelerating {
            imageView.transform.ty = translation
        }
        
        guard scrollView.isDragging, !scrollView.isDecelerating else { return }
        
        if !transitionIsUserDriving && abs(translation) > 10.0 {
            transitionIsUserDriving = true
            delegate?.photoViewCell(self, didChangeTransitionState: .began)
        }
        
        guard transitionIsUserDriving else { return }
        delegate?.photoViewCell(self, didChangeTransitionState: .updating(progress: currentProgress()))
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        guard transitionIsUserDriving else { return }
        transitionIsUserDriving = false
        
        if abs(currentProgress()) > 0.2 || abs(velocity.y) > 0.5 {
            targetContentOffset.pointee = scrollView.contentOffset
            scrollView.contentInset.top = -scrollView.contentOffset.y
            delegate?.photoViewCell(self, didChangeTransitionState: .finishing)
        } else {
            delegate?.photoViewCell(self, didChangeTransitionState: .cancelling)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewIsZoomingFast = scrollView.isZooming
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewIsZoomingFast = false
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateInsets()
    }
    
}

private extension PhotoViewCell {
    
    // MARK: - Private Methods
    
    func setupScrollView() {
        addSubview(scrollView)
        scrollView.delegate = self
        
        scrollView.bouncesZoom = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .fast
        
        scrollView.autoresizesSubviews = false
        scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    func setupImageView() {
        scrollView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
    }
    
    func updateInsets() {
        let verticalInset = bounds.height > imageView.frame.height ?
            ceil((bounds.height - imageView.frame.height) / 2) : 0
        
        let horizontalInset = bounds.width > imageView.frame.width ?
            ceil((bounds.width - imageView.frame.width) / 2) : 0
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
    
    func currentVerticalTranslation() -> CGFloat {
        return -(scrollView.contentInset.top + scrollView.contentOffset.y)
    }
    
    func currentProgress() -> CGFloat {
        return currentVerticalTranslation() / scrollView.bounds.height * 2
    }
    
    @objc func handleSingleTap() {
        delegate?.photoViewCellDidTap(self)
    }
    
    @objc func handleDoubleTap() {
        if scrollView.zoomScale != scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let point = doubleTapRecoginzer.location(in: self)
            let pointInImageView = imageView.convert(point, from: self)
            
            let size = CGSize(width: bounds.width / scrollView.maximumZoomScale,
                              height: bounds.height / scrollView.maximumZoomScale)
            
            let origin = CGPoint(x: pointInImageView.x - size.width / 2.0,
                                 y: pointInImageView.y - size.width / 2.0)
            
            scrollView.zoom(to: CGRect(origin: origin, size: size), animated: true)
        }
    }
    
}
