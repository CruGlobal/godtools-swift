//
//  AttachmentResource.swift
//  godtools
//
//  Created by Ryan Carlson on 5/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SwiftyJSON

class AttachmentResource: JSONResource {
    
    override class var type: String {
        return "attachment"
    }
    
    override class var attributeMappings: [String: String] {
        return ["sha256": "sha256"]
    }
    
    var id = ""
    var sha256 = ""
    
    static func initializeFrom(json: JSON, resourceID: String) -> [AttachmentResource] {
        var attachments = [AttachmentResource]()
        for attachment in json.arrayValue {
            guard let type = attachment["type"].string, type == "attachment" else { continue }
            guard let rID = attachment["relationships"]["resource"]["data"]["id"].string, rID == resourceID else { continue }
            
            let attachmentResource = AttachmentResource();
            
            if let id = attachment["id"].string {
                attachmentResource.id = id
            }
            if let sha256 = attachment["attributes"]["sha256"].string {
                attachmentResource.sha256 = sha256
            }
            
            attachments.append(attachmentResource)
        }
        return attachments
    }
}
