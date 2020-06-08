//
//  SingleRequestOperation.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class SingleRequestOperation {
    
    func execute<SuccessType: Decodable, ClientApiErrorType: Decodable>(operation: RequestOperation, completeOnMainThread: Bool, complete: @escaping ((_ response: RequestResponse, _ result: ResponseResult<SuccessType, ClientApiErrorType>) -> Void)) -> OperationQueue {
        
        let queue = OperationQueue()
        
        operation.completionHandler { (response: RequestResponse) in
            
            response.log()
            
            let result: ResponseResult<SuccessType, ClientApiErrorType> = response.getResult()
            
            if completeOnMainThread {
                DispatchQueue.main.async {
                    complete(response, result)
                }
            }
            else {
                complete(response, result)
            }
        }
        
        queue.addOperations([operation], waitUntilFinished: false)
        
        return queue
    }
}
