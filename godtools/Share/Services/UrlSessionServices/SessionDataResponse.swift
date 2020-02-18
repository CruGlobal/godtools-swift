//
//  SessionDataResponse.swift
//  godtools
//
//  Created by Levi Eggert on 2/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct SessionDataResponse {
        
    let urlRequest: URLRequest
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
    var cancelled: Bool {
        return errorCode == Int(CFNetworkErrors.cfurlErrorCancelled.rawValue)
    }
    var notConnected: Bool {
        return errorCode == Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue)
    }
    #endif
    
    func log() {
        
        print("\n SessionDataResponse log() -----")
        
        print("  request.url: \(String(describing: urlRequest.url?.absoluteString))")
        print("  request.headers: \(String(describing: urlRequest.allHTTPHeaderFields))")
        
        if let httpBody = urlRequest.httpBody {
            if let stringBody = String(data: httpBody, encoding: .utf8) {
                print("  \nbody: \(stringBody)")
            }
        }
        
        print("  error: \(String(describing: error))")
        print("  errorOccurred: \(error != nil)")
        print("  httpStatusCode: \(String(describing: httpStatusCode))")
        
        var responseJson: Any?
        if let data = data {
            do {
                responseJson = try JSONSerialization.jsonObject(with: data, options: [])
            }
            catch let error {
                print("  Failed to serialize response data with error: \(error)")
            }
        }
        
        if let httpResponse = urlResponse as? HTTPURLResponse {
            print("  response headers: \(httpResponse.allHeaderFields)")
        }
        
        print("  response json: \(String(describing: responseJson))")
        
        if responseJson == nil, let data = data, let responseString = String(data: data, encoding: .utf8) {
            print("  response string: \(responseString)")
        }
        print("\n")
    }
}
