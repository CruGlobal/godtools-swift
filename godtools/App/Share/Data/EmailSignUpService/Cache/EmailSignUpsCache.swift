//
//  EmailSignUpsCache.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

final class EmailSignUpsCache {
    
    let persistence: any Persistence<EmailSignUpDataModel, EmailSignUpDataModel>
    
    init(persistence: any Persistence<EmailSignUpDataModel, EmailSignUpDataModel>) {
        
        self.persistence = persistence
    }
    
    func getEmailIsRegistered(email: String) throws -> Bool {
        return try persistence.getDataModel(id: email)?.isRegistered ?? false
    }
}
