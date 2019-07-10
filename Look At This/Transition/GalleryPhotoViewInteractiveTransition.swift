//
//  GalleryPhotoViewInteractiveTransition.swift
//  Look At This
//
//  Created by Artem Kirillov on 10/07/2019.
//

import UIKit

enum InteractiveTransitionState {
    case updating(progress: CGFloat)
    case finishing
    case cancelling
}

class GalleryPhotoViewInteractiveTransition: NSObject, UIViewControllerInteractiveTransitioning {
    
    // MARK: - Constructors
    
    init(galleryPhotoViewTransition: GalleryPhotoViewTransition) {
        self.galleryPhotoViewTransition = galleryPhotoViewTransition
        
        super.init()
        
        galleryPhotoViewTransition.photoViewController.interactiveTransitionDelegate = self
    }
    
    // MARK: - Public Methods
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        guard let toView = transitionContext.view(forKey: .to) else {
            transitionContext.finishInteractiveTransition()
            transitionContext.completeTransition(true)
            return
        }
        
        self.toView = toView
        self.containerView = transitionContext.containerView
        
        galleryPhotoViewTransition.setupViews(containerView: containerView, toView: toView)
    }
    
    // MARK: - Private Properties
    
    private var containerView = UIView()
    private var toView = UIView()
    
    private var imageFrame: CGRect = .zero
    private var transitionContext: UIViewControllerContextTransitioning?
    private let galleryPhotoViewTransition: GalleryPhotoViewTransition
    
}

// MARK: - InteractiveTransitionDelegate

extension GalleryPhotoViewInteractiveTransition: InteractiveTransitionDelegate {
    
    func interactiveTransitionDidChangeState(_ state: InteractiveTransitionState) {
        switch state {
        case .updating(let progress):
            galleryPhotoViewTransition.update(progress: progress)
            transitionContext?.updateInteractiveTransition(progress)
            
        case .finishing:
            galleryPhotoViewTransition.animate(
                withDuration: 0.3,
                containerView: containerView,
                toView: toView) { [weak self] in
                    self?.galleryPhotoViewTransition.removeViews()
                    self?.transitionContext?.finishInteractiveTransition()
                    self?.transitionContext?.completeTransition(true)
            }
            
        case .cancelling:
            galleryPhotoViewTransition.animate(
                reversed: true,
                withDuration: 0.3,
                containerView: containerView,
                toView: toView) { [weak self] in
                    self?.transitionContext?.cancelInteractiveTransition()
                    self?.transitionContext?.completeTransition(false)
            }
        }
    }
    
}
