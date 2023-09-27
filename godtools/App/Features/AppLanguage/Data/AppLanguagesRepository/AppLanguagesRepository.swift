//
//  AppLanguagesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class AppLanguagesRepository {
    
    init() {
        
    }
    
    func getLanguages() -> [AppLanguageDataModel] {
        
        let appLanguages: [AppLanguageDataModel] = [
            AppLanguageDataModel(languageCode: "ar", languageDirection: .rightToLeft),
            AppLanguageDataModel(languageCode: "en", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "es", languageDirection: .leftToRight)
        ]
        
        return appLanguages
    }
    
    func getLanguage(languageCode: String) -> AppLanguageDataModel? {
        
        return getLanguages().filter({
            $0.languageCode.lowercased() == languageCode.lowercased()
        }).first
    }
}
