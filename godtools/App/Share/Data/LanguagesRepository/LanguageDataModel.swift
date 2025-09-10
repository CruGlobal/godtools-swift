//
//  LanguageDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct LanguageDataModel: LanguageDataModelInterface {
    
    let code: BCP47LanguageIdentifier
    let directionString: String
    let id: String
    let name: String
    let type: String
    let forceLanguageName: Bool
    
    init(interface: LanguageDataModelInterface) {
        
        self.code = interface.code
        self.directionString = interface.directionString
        self.id = interface.id
        self.name = interface.name
        self.type = interface.type
        self.forceLanguageName = interface.forceLanguageName
    }
}
