//
//  RequestResponse+RequestResult.swift
//  godtools
//
//  Created by Levi Eggert on 2/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

extension RequestResponse {
    
    func getResult<SuccessType: Decodable, ClientErrorType: Decodable>() -> RequestResult<SuccessType, ClientErrorType> {
        
        if let error = error {
            return .failure(clientError: nil, error: error)
        }
        else if let data = data {
            
            if httpStatusCode >= 200 && httpStatusCode < 201 {
                
                do {
                    let object: SuccessType = try JSONDecoder().decode(SuccessType.self, from: data)
                    return .success(object: object)
                }
                catch let error {
                    return .failure(clientError: nil, error: error)
                }
            }
            else if httpStatusCode >= 400 {
                
                do {
                    let object: ClientErrorType = try JSONDecoder().decode(ClientErrorType.self, from: data)
                    return .failure(clientError: object, error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "An error on the client server occurred."]))
                }
                catch let error {
                    return .failure(clientError: nil, error: error)
                }
            }
        }
        
        return .failure(clientError: nil, error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."]))
    }
}
