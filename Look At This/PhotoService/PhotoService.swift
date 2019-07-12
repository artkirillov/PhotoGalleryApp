//
//  PhotoService.swift
//  Look At This
//
//  Created by Artem Kirillov on 12/07/2019.
//

import UIKit

class PhotoServiceImpl: PhotoService {
    
    // MARK: - Public Properties
    
    var count: Int {
        return photos.count
    }
    
    private(set) var hasNextPage: Bool = true
    
    private(set) var isCancelled = false
    
    // MARK: - Public Methods
    
    func photoInteractor(forPhotoWithIndex index: Int) -> PhotoInteractor? {
        guard index >= 0 && index < photos.count,
            let url = URL(string: photos[index].urls.regular) else { return nil }
        
        return PhotoInteractorImpl(author: photos[index].user.name, url: url)
    }
    
    func fetchNextPage(completion: @escaping (Error?) -> Void) {
        guard !isFetching else { return }
        isFetching = true
        
        page += 1
        requestPhotos(
            page: page,
            success: { [weak self] photos in
                self?.isFetching = false
                self?.photos += photos
                completion(nil)
            },
            failure: { error in completion(error) }
        )
    }
    
    func cancel() {
        isCancelled = true
        imageDataTask?.cancel()
    }
    
    // MARK: - Private Properties
    
    private var imageDataTask: URLSessionDataTask?
    private var photos: [Photo] = []
    private var page: Int = 0
    private var isFetching = false
    
}

private extension PhotoServiceImpl {
    
    // MARK: - Private Nested
    
    struct Configuration {
        static let baseUrl = "https://api.unsplash.com/photos"
        static let clientId = "Client-ID 000e4d65efecdd8673e24e1878758fe22494dd354413b75ae403b32c3e9879cc"
    }
    
    // MARK: - Private Methods
    
    func requestPhotos(
        page: Int,
        success: @escaping ([Photo]) -> Void,
        failure: @escaping (Error) -> Void
        )
    {
        guard var urlComponents = URLComponents(string: Configuration.baseUrl) else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "100")
        ]
        
        guard let url = urlComponents.url else { return }
        
        let request = NSMutableURLRequest(url: url)
        request.addValue(Configuration.clientId, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            guard error == nil else {
                print("ERROR: \(String(describing: error))")
                DispatchQueue.main.async { failure(error!) }
                return
            }
            
            guard let data = data else {
                print("NO DATA")
                return
            }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let object = try jsonDecoder.decode([Photo].self, from: data)
                DispatchQueue.main.async { success(object) }
            } catch {
                DispatchQueue.main.async { failure(error) }
                print("ERROR: \(String(describing: error))")
            }
        })
        
        task.resume()
    }
    
}
