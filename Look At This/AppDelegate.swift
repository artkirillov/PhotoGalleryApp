//
//  AppDelegate.swift
//  Look At This
//
//  Created by Artem Kirillov on 07/07/2019.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Public Properties

    var window: UIWindow?
    
    // MARK: - Public Methods

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        let controller = GalleryViewController(photoService: photoService)
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.navigationBar.barStyle = .blackTranslucent
        navigationController.navigationBar.tintColor = .white
        navigationController.delegate = self

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
    
    // MARK: - Private Properties
    
    private let photoService = PhotoServiceImpl()
    
}

extension AppDelegate: UINavigationControllerDelegate {
    
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        let isPresenting = operation == .push
        
        guard let galleryViewController = (isPresenting ? fromVC : toVC) as? GalleryViewController,
        let photoViewController = (isPresenting ? toVC : fromVC) as? PhotoViewController else { return nil }
        
        return GalleryPhotoViewTransition(
            isPresenting: isPresenting,
            duration: 0.3,
            image: galleryViewController.selectedImage ?? UIImage(),
            galleryViewController: galleryViewController, photoViewController: photoViewController
        )
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    {
        guard let transition = animationController as? GalleryPhotoViewTransition,
            transition.photoViewController.interactiveTransitionIsActive, !transition.isPresenting else { return nil }
        return GalleryPhotoViewInteractiveTransition(galleryPhotoViewTransition: transition)
        
    }
    
}

