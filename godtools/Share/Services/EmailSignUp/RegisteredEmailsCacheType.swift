//
//  RegisteredEmailsCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 12/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol RegisteredEmailsCacheType {
        
    func storeRegisteredEmail(model: RegisteredEmailModel)
    func getRegisteredEmail(email: String) -> RegisteredEmailModel?
}
