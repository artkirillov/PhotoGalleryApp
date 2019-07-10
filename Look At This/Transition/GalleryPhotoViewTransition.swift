//
//  GalleryPhotoViewTransition.swift
//  Look At This
//
//  Created by Artem Kirillov on 10/07/2019.
//

import UIKit

class GalleryPhotoViewTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - Public Properties
    
    let duration: TimeInterval
    let isPresenting: Bool
    let image: UIImage
    let galleryViewController: GalleryViewController
    let photoViewController: PhotoViewController
    
    // MARK: - Constructors
    
    init(
        isPresenting: Bool,
        duration: TimeInterval,
        image: UIImage,
        galleryViewController: GalleryViewController,
        photoViewController: PhotoViewController)
    {
        self.isPresenting = isPresenting
        self.duration = duration
        self.image = image
        self.galleryViewController = galleryViewController
        self.photoViewController = photoViewController
    }
    
    // MARK: - Public Methods
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(true)
            return
        }
        setupViews(containerView: transitionContext.containerView, toView: toView)
        animate(withDuration: duration,
                containerView: transitionContext.containerView,
                toView: toView) { [weak transitionContext] in
                    guard let transitionContext = transitionContext else { return }
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    func animate(reversed: Bool = false, withDuration duration: TimeInterval, containerView: UIView,
                 toView: UIView, completion: @escaping () -> Void)
    {
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            usingSpringWithDamping: reversed ? 1.0 : 0.8,
            initialSpringVelocity: 0,
            options: .curveEaseOut,
            animations: {
                self.imageView.frame = self.isPresenting || reversed ? self.finalFrame : self.startFrame
                self.dimmingView.alpha = self.isPresenting || reversed ? 1.0 : 0.0
        },
            completion: { [weak self] _ in
                self?.removeViews()
                toView.alpha = 1.0
                completion()
        })
    }
    
    func setupViews(containerView: UIView, toView: UIView) {
        let screenFrame = toView.frame
        let navBarMaxY = galleryViewController.navigationController?.navigationBar.frame.maxY ?? 0.0
        let originFrame = galleryViewController.selectedItemFrame ?? .zero
        
        startFrame = self.startFrame(
            isPresenting: isPresenting,
            navBarMaxY: navBarMaxY,
            originFrame: originFrame
        )
        
        finalFrame = self.finalFrame(
            isPresenting: isPresenting,
            screenFrame: screenFrame,
            imageSize: image.size
        )
        
        toView.alpha = isPresenting ? 0.0 : 1.0
        containerView.addSubview(toView)
        
        emptySpaceView.frame = startFrame
        emptySpaceView.backgroundColor = .black
        containerView.addSubview(emptySpaceView)
        
        dimmingView.frame = screenFrame
        dimmingView.backgroundColor = .black
        dimmingView.alpha = isPresenting ? 0.0 : 1.0
        containerView.addSubview(dimmingView)
        
        imageView.image = image
        imageView.frame = isPresenting ? startFrame : finalFrame
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        containerView.addSubview(imageView)
    }
    
    func removeViews() {
        emptySpaceView.removeFromSuperview()
        dimmingView.removeFromSuperview()
        imageView.removeFromSuperview()
    }
    
    func update(progress: CGFloat) {
        imageView.frame.origin.y = finalFrame.origin.y + progress * dimmingView.frame.height
        dimmingView.alpha = 1.0 - abs(1.5 * progress)
    }
    
    // MARK: - Private Properties
    
    private let emptySpaceView = UIView()
    private let dimmingView = UIView()
    private let imageView = UIImageView()
    
    private var startFrame = CGRect.zero
    private var finalFrame = CGRect.zero
    
}

private extension GalleryPhotoViewTransition {
    
    // MARK: - Private Methods
    
    func finalFrame(isPresenting: Bool, screenFrame: CGRect, imageSize: CGSize) -> CGRect {
        if imageSize.width / imageSize.height >= screenFrame.width / screenFrame.height {
            let height = ceil(screenFrame.width / imageSize.width * imageSize.height)
            return CGRect(x: 0, y: ceil((screenFrame.height - height) / 2),
                          width: screenFrame.width, height: height)
        } else {
            let width = ceil(screenFrame.height / imageSize.height * imageSize.width)
            return CGRect(x: ceil((screenFrame.width - width) / 2), y: 0,
                          width: width, height: screenFrame.height)
        }
    }
    
    func startFrame(isPresenting: Bool, navBarMaxY: CGFloat?, originFrame: CGRect) -> CGRect {
        let startFrameY = navBarMaxY ?? 0.0
        return CGRect(x: originFrame.minX,
                      y: max(startFrameY, originFrame.minY),
                      width: originFrame.width,
                      height: originFrame.minY < startFrameY ?
                        originFrame.maxY - startFrameY : originFrame.height
        )
    }
    
}
