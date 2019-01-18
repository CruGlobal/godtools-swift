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
    @objc dynamic var name: String?
    @objc dynamic var email: String?
    @objc dynamic var destinationId: String?
    @objc dynamic var languageId: String?
    @objc dynamic var responseStatusCode: String?
    @objc dynamic var createdAtTime: NSDate?
    @objc dynamic var retryCount: Int = 0
    
    convenience init(params: [String: String]) {
        self.init()
        
        name = params["name"]
        email = params["email"]
        destinationId = params["destination_id"]
        languageId = params["language_id"]
    }
}
