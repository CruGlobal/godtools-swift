//
//  FollowUp.swift
//  godtools
//
//  Created by Ryan Carlson on 6/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import Spine

class FollowUpResource: Resource {
    var email: String?
    var name: String?
    var destination: String?
    var language: String?
    
    convenience init(emailP: String, name: String, destination: String, language: String) {
        self.init()
        self.email = email
        self.name = name
        self.destination = destination
        self.language = language
    }
    
    override class var resourceType: ResourceType {
        return "follow_up"
    }
    
    override class var fields: [Field] {
        return fieldsFromDictionary([
            "email" : Attribute(),
            "name" : Attribute(),
            "destination" : Attribute(),
            "language" : Attribute()
            ])
    }
}
