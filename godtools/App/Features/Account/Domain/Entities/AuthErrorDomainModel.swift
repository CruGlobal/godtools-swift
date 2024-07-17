//
//  AuthErrorDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum AuthErrorDomainModel: Error {
    
    case accountAlreadyExists
    case accountNotFound
    case other(error: Error)
}

extension AuthErrorDomainModel {
    
    func getError() -> Error? {
        switch self {
        case .accountAlreadyExists:
            return nil
        case .accountNotFound:
            return nil
        case .other(let error):
            return error
        }
    }
}
