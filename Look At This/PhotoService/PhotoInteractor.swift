//
//  PhotoInteractor.swift
//  Look At This
//
//  Created by Artem Kirillov on 12/07/2019.
//

import UIKit

class PhotoInteractorImpl: PhotoInteractor {
    
    // MARK: - Public Properties
    
    let author: String
    
    // MARK: - Constructors
    
    init(author: String, url: URL) {
        self.author = author
        self.url = url
    }
    
    // MARK: - Public Methods
    
    func downloadPhoto(completion: @escaping (UIImage?, Error?) -> Void) {
        if let cachedResponse = PhotoInteractorImpl.cache.cachedResponse(for: URLRequest(url: url)),
            let image = UIImage(data: cachedResponse.data) {
            completion(image, nil)
            return
        }
        
        imageDataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, _, error) in
            self?.imageDataTask = nil
            
            if let error = error {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            guard let data = data, let image = UIImage(data: data), error == nil else { return }
            DispatchQueue.main.async { completion(image, nil) }
        }
        
        imageDataTask?.resume()
        
    }
    
    func cancelDownloading() {
        imageDataTask?.cancel()
    }
    
    // MARK: - Private Properties
    
    private let url: URL
    private var imageDataTask: URLSessionDataTask?
    private static let cache = URLCache(
        memoryCapacity: 50 * 1024 * 1024,
        diskCapacity: 100 * 1024 * 1024,
        diskPath: "photo"
    )
    
}
