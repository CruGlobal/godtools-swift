//
//  RequestResponse+Log.swift
//  godtools
//
//  Created by Levi Eggert on 2/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

extension RequestResponse {
    
    func log() {
        
        RequestResponse.log(urlRequest: urlRequest, data: data, urlResponse: urlResponse, requestError: requestError)
    }
    
    static func log(urlRequest: URLRequest?, data: Data?, urlResponse: URLResponse?, requestError: Error?) {
                
        print("\n \(String(describing: RequestResponse.self)) log() -----")
        
        print("  request.url: \(String(describing: urlRequest?.url?.absoluteString))")
        print("  request.headers: \(String(describing: urlRequest?.allHTTPHeaderFields))")
        
        if let httpBody = urlRequest?.httpBody {
            if let stringBody = String(data: httpBody, encoding: .utf8) {
                print("  \nbody: \(stringBody)")
            }
        }
        
        if let data = data {
            print("  data: \(data)")
        }
        
        print("  requestError: \(String(describing: requestError))")
        print("  httpStatusCode: \(String(describing: (urlResponse as? HTTPURLResponse)?.statusCode))")
        
        if let mimeType = urlResponse?.mimeType {
            print("  mimeType: \(mimeType)")
        }
        
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
