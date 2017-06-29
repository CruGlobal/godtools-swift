//
//  FollowUp.swift
//  godtools
//
//  Created by Ryan Carlson on 6/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class FollowUp: Object {
    dynamic var name: String?
    dynamic var email: String?
    dynamic var destinationId: String?
    dynamic var languageId: String?
    dynamic var responseStatusCode: String?
    dynamic var createdAtTime: NSDate?
    dynamic var retryCount: Int = 0
    
    convenience init(jsonAPIFollowUp: FollowUpResource) {
        self.init()
        
        name = jsonAPIFollowUp.name
        email = jsonAPIFollowUp.email
        destinationId = jsonAPIFollowUp.destination_id
        languageId = jsonAPIFollowUp.language_id
    }
}
