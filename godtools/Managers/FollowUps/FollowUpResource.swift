//
//  FollowUp.swift
//  godtools
//
//  Created by Ryan Carlson on 6/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

class FollowUpResource {
    var email: String?
    var name: String?
    var destination_id: String?
    var language_id: String?
    
    convenience init(email: String, name: String, destination: String, language: String) {
        self.init()
        self.email = email
        self.name = name
        self.destination_id = destination
        self.language_id = language
    }
}
