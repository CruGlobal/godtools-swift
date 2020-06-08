//
//  ResponseResult.swift
//  godtools
//
//  Created by Levi Eggert on 2/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ResponseResult<SuccessType: Decodable, ClientApiErrorType: Decodable> {
    
    case success(object: SuccessType?, decodeError: Error?)
    case failure(error: ResponseError<ClientApiErrorType>)
}
