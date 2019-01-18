//
//  LanguageResource.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

class LanguageResource: GodToolsJSONResource {
    
    @objc var id = ""
    @objc var code = ""
    @objc var direction = ""
}

// Mark - JSONResource protocol functions

extension LanguageResource {

    override func type() -> String {
        return "language"
    }
}
