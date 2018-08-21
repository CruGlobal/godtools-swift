//
//  LanguageResource.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SwiftyJSON

class LanguageResource {
    
    var id = ""
    var code = ""
    var direction = ""
    
    static func initializeFrom(data: Data) -> [LanguageResource] {
        var languages = [LanguageResource]();
        
        let json = JSON(data: data)["data"]
        
        for language in json.arrayValue {
            let languageResource = LanguageResource();
            
            if let id = language["id"].string {
                languageResource.id = id
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
}
