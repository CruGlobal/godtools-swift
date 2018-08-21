//
//  LanguageResource.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import Spine
import SwiftyJSON

class LanguageResource: Resource {
    
    var id2 = ""
    var code = ""
    var direction = ""
    
    static func initializeFrom(data: Data) -> [LanguageResource] {
        var languages = [LanguageResource]();
        
        let json = JSON(data: data)["data"]
        
        for language in json.arrayValue {
            let languageResource = LanguageResource();
            
            if let id2 = language["id"].string {
                languageResource.id2 = id2
            }
            
            if let code = language["attributes"]["code"].string {
                languageResource.code = code
            }
            
            if let direction = language["attributes"]["direction"].string{
                languageResource.direction = direction
            }
            languages.append(languageResource);
        }
        
        return languages;
    }
    
    override class var resourceType: ResourceType {
        return "language"
    }
    
    override class var fields: [Field] {
        return fieldsFromDictionary([
            "code" : Attribute(),
            "direction" : Attribute()
            ])
    }
}
