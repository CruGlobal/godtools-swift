//
//  MobileContentAttachmentsApi.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

class MobileContentAttachmentsApi {
    
    private let session: URLSession
    private let baseUrl: String
    
    init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession) {
                    
        session = ignoreCacheSession.session
        baseUrl = config.mobileContentApiBaseUrl
    }
    
    func getAttachmentFile(url: URL) -> AnyPublisher<UrlRequestResponse, Error> {
        
        let urlRequest: URLRequest = URLRequest(url: url)
        
        return session.sendUrlRequestPublisher(urlRequest: urlRequest)
            .eraseToAnyPublisher()
    }
}
