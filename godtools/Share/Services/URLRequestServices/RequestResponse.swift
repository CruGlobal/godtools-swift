//
//  RequestResponse.swift
//  godtools
//
//  Created by Levi Eggert on 2/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct RequestResponse {
        
    let urlRequest: URLRequest?
    let data: Data?
    let urlResponse: URLResponse?
    let error: Error?
    
    var httpStatusCode: Int {
        return (urlResponse as? HTTPURLResponse)?.statusCode ?? -1
    }
    
    var errorCode: Int? {
        return (error as NSError?)?.code ?? nil
    }
    
    var unauthorized: Bool {
        return httpStatusCode == 401
    }
    
    #if os(iOS)
    var requestCancelled: Bool {
        return errorCode == Int(CFNetworkErrors.cfurlErrorCancelled.rawValue)
    }
    var notConnectedToInternet: Bool {
        return errorCode == Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue)
    }
    #endif
}
