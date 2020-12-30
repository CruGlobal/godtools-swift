//
//  RequestResponse.swift
//  godtools
//
//  Created by Levi Eggert on 2/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class RequestResponse {
            
    let urlRequest: URLRequest?
    let data: Data?
    let urlResponse: URLResponse?
    let requestError: Error?
    
    init(urlRequest: URLRequest?, data: Data?, urlResponse: URLResponse?, requestError: Error?) {
                
        self.urlRequest = urlRequest
        self.data = data
        self.urlResponse = urlResponse
        self.requestError = requestError
    }
    
    var httpStatusCode: Int? {
        return (urlResponse as? HTTPURLResponse)?.statusCode
    }
    
    var requestErrorCode: Int? {
        return (requestError as NSError?)?.code ?? nil
    }
    
    #if os(iOS)
    var requestCancelled: Bool {
        return requestErrorCode == Int(CFNetworkErrors.cfurlErrorCancelled.rawValue)
    }
    
    var notConnectedToInternet: Bool {
        return requestErrorCode == Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue)
    }
    #endif
}
