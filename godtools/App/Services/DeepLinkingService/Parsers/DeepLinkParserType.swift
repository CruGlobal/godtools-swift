//
//  DeepLinkParserType.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol DeepLinkParserType {
                
    func parse(incomingDeepLink: IncomingDeepLinkType) -> ParsedDeepLinkType?
    func getUrlPathComponents(url: URL) -> [String]
    func getDecodedUrlQuery<T: Codable>(url: URL) -> T?
}

extension DeepLinkParserType {
    
    func getUrlPathComponents(url: URL) -> [String] {
        return url.pathComponents.filter({$0 != "/"})
    }
    
    func getDecodedUrlQuery<T: Codable>(url: URL) -> T? {
        
        let queryResult: Result<T?, Error> = JsonServices().decodeUrlQuery(url: url)
        let urlQueryParameters: T?
        
        switch queryResult {
        case .success(let queryParameters):
            urlQueryParameters = queryParameters
        case .failure( _):
            urlQueryParameters = nil
        }
        
        return urlQueryParameters
    }
}
