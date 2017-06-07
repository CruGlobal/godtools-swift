//
//  TractEmailProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractEmailProperties: TractElementProperties {
    
    var subject: String?
    var content: String?
    var html: Bool = true
    
    override func load(_ properties: [String: Any]) {
        super.load(properties)
        
        for property in properties.keys {
            switch property {
            case "subject":
                self.subject = properties[property] as! String?
            case "content":
                self.content = properties[property] as! String?
            case "html":
                self.html = (properties[property] as! String) == "true"
            default: break
            }
        }
    }
    
}
