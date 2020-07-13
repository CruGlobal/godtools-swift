//
//  FollowUpModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct FollowUpModel: FollowUpModelType {
    
    let id: String
    let name: String
    let email: String
    let destinationId: Int
    let languageId: Int
    
    init(name: String, email: String, destinationId: Int, languageId: Int) {
        
        self.id = UUID().uuidString
        self.name = name
        self.email = email
        self.destinationId = destinationId
        self.languageId = languageId
    }
    
    init(model: FollowUpModelType) {
        
        id = model.id
        name = model.name
        email = model.email
        destinationId = model.destinationId
        languageId = model.languageId
    }
}
