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
    
    convenience init(params: [String: String]) {
        self.init()
        
        name = params["name"]
        email = params["email"]
        destinationId = params["destination_id"]
        languageId = params["language_id"]
    }
}
