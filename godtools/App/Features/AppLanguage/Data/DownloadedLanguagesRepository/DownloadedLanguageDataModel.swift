//
//  DownloadedLanguageDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct DownloadedLanguageDataModel {
    
    let createdAt: Date
    let languageId: String
    
    init(languageId: String) {
        
        self.createdAt = Date()
        self.languageId = languageId
    }
    
    init(realmDownloadedLanguage: RealmDownloadedLanguage) {
        
        createdAt = realmDownloadedLanguage.createdAt
        languageId = realmDownloadedLanguage.languageId
    }
}
