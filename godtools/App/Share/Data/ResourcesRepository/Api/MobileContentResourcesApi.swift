//
//  MobileContentResourcesApi.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

class MobileContentResourcesApi {
    
    private let session: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseUrl: String
    
    init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession) {
                    
        self.session = ignoreCacheSession.session
        self.baseUrl = config.mobileContentApiBaseUrl
    }
    
    private func getResourcesPlusLatestTranslationsAndAttachmentsRequest() -> URLRequest {
        
        return requestBuilder.build(
            session: session,
            urlString: baseUrl + "/resources?filter[system]=GodTools&include=latest-translations,attachments",
            method: .get,
            headers: nil,
            httpBody: nil,
            queryItems: nil
        )
    }
    
    func getResourcesPlusLatestTranslationsAndAttachments() -> AnyPublisher<ResourcesPlusLatestTranslationsAndAttachmentsModel, URLResponseError> {
        
        return session.dataTaskPublisher(for: getResourcesPlusLatestTranslationsAndAttachmentsRequest())
            .tryMap {
                
                let urlResponseObject = URLResponseObject(data: $0.data, urlResponse: $0.response)
                
                guard urlResponseObject.isSuccessHttpStatusCode else {
                    throw URLResponseError.statusCode(urlResponseObject: urlResponseObject)
                }
                
                return urlResponseObject.data
            }
            .mapError {
                return URLResponseError.requestError(error: $0 as Error)
            }
            .decode(type: ResourcesPlusLatestTranslationsAndAttachmentsModel.self, decoder: JSONDecoder())
            .mapError {
                return URLResponseError.decodeError(error: $0)
            }
            .eraseToAnyPublisher()
    }
}
