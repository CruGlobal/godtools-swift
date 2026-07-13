//
//  FollowUpDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct FollowUpDataModel: Sendable {
    
    let id: String
    let name: String
    let email: String
    let destinationId: Int
    let languageId: Int
    
    init(id: String, name: String, email: String, destinationId: Int, languageId: Int) {
        
        self.id = id
        self.name = name
        self.email = email
        self.destinationId = destinationId
        self.languageId = languageId
    }
    
    init(id: String, followUp: FollowUp) {
        
        self.id = id
        self.name = followUp.name
        self.email = followUp.email
        self.destinationId = followUp.destinationId
        self.languageId = followUp.languageId
    }
    
    func toFollowUp() -> FollowUp {
        return FollowUp(name: name, email: email, destinationId: destinationId, languageId: languageId)
    }
}
