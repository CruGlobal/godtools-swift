//
//  RequestResponse+ResponseResult.swift
//  godtools
//
//  Created by Levi Eggert on 2/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

extension RequestResponse {
        
    func getResult<SuccessType: Decodable, ClientApiErrorType: Decodable>() -> ResponseResult<SuccessType, ClientApiErrorType> {
        
        let httpStatusCode: Int = (urlResponse as? HTTPURLResponse)?.statusCode ?? -1
        let httpStatusCodeSuccessful: Bool = httpStatusCode >= 200 && httpStatusCode < 400
        
        var successData: SuccessType?
        var responseError: ResponseError<ClientApiErrorType>?
        var decodeError: Error?
        
        if let requestError = requestError {
            
            let requestErrorCode: Int? = (requestError as NSError?)?.code ?? nil
            
            if requestErrorCode == Int(CFNetworkErrors.cfurlErrorCancelled.rawValue) {
                responseError = .requestCancelled
            }
            else if requestErrorCode == Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue) {
                responseError = .noNetworkConnection
            }
            else {
                responseError = .requestFailed(error: requestError)
            }
        }
        else if !httpStatusCodeSuccessful {
            
            if let data = data {
                do {
                    let httpClientError: ClientApiErrorType? = try JSONDecoder().decode(ClientApiErrorType.self, from: data)
                    responseError = .httpClientError(error: httpClientError)
                }
                catch let error {
                    responseError = .httpClientError(error: nil)
                    decodeError = error
                }
            }
            else {
                responseError = .httpClientError(error: nil)
            }
        }
        else { // Success
            
            if let data = data {
                do {
                    successData = try JSONDecoder().decode(SuccessType.self, from: data)
                }
                catch let error {
                    successData = nil
                    decodeError = error
                }
            }
            else {
                successData = nil
            }
        }
                
        if let responseError = responseError {
            return .failure(error: responseError)
        }
        else {
            return .success(object: successData, decodeError: decodeError)
        }
    }
}
