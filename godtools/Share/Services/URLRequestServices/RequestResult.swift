//
//  RequestResult.swift
//  godtools
//
//  Created by Levi Eggert on 2/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum RequestResult<SuccessType, ClientErrorType> {
    
    case success(object: SuccessType?)
    case failure(clientError: ClientErrorType?, error: Error)
}
