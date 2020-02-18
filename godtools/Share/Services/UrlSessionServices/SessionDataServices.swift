//
//  SessionDataServices.swift
//  godtools
//
//  Created by Levi Eggert on 2/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol SessionDataServices {
    
}

extension SessionDataServices {
    
    func getSessionDataObject<T: Decodable>(operation: SessionDataOperation, complete: @escaping ((_ result: Result<T?, Error>) -> Void)) -> OperationQueue? {
        
        let queue: OperationQueue = OperationQueue()
        
        operation.completion = { (response: SessionDataResponse) in
                        
            let result: Result<T?, Error>
            
            if let error = response.error {
                result = .failure(error)
            }
            else if response.httpStatusCode == 200, let data = response.data {
                do {
                    result = .success(try JSONDecoder().decode(T.self, from: data))
                }
                catch let error {
                    result = .failure(error)
                }
            }
            else {
                result = .success(nil)
            }
            
            DispatchQueue.main.async {
                complete(result)
            }
        }
        
        queue.addOperations([operation], waitUntilFinished: false)
                
        return queue
    }
}
