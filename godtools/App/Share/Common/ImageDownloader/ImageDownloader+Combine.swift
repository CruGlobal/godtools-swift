//
//  ImageDownloader+Combine.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

extension ImageDownloader {
    
    func downloadPublisher(urlString: String?) -> AnyPublisher<Image?, Never> {
        
        guard let urlString = urlString else {
            return Just(nil)
                .eraseToAnyPublisher()
        }
        
        guard let url = URL(string: urlString) else {
            return Just(nil)
                .eraseToAnyPublisher()
        }
        
        let urlRequest: URLRequest = URLRequest(url: url)
        
        if let cachedImageData = getImageCache().getImageData(urlRequest: urlRequest), let cachedUIImage = UIImage(data: cachedImageData) {
            
            return Just(Image(uiImage: cachedUIImage))
                .eraseToAnyPublisher()
        }
        
        return getSession().dataTaskPublisher(for: url)
            .map { (data: Data, urlResponse: URLResponse) in
                
                let httpStatusCode: Int = (urlResponse as? HTTPURLResponse)?.statusCode ?? -1
                
                let isSuccessfulHttpStatusCode: Bool = httpStatusCode >= 200 && httpStatusCode < 400
                
                guard isSuccessfulHttpStatusCode else {
                    return nil
                }
                
                guard let uiImage = UIImage(data: data) else {
                    return nil
                }
                
                self.getImageCache().storeImageData(imageData: data, urlResponse: urlResponse, urlRequest: urlRequest)
                
                return Image(uiImage: uiImage)
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
