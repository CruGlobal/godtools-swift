//
//  AuthErrorDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum AuthErrorDomainModel {
    
    case accountAlreadyExists
    case accountNotFound
    case other(error: Error)
}
