//
//  TestsGetLanguageNameInEnglishRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 9/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class TestsGetLanguageNameInEnglishRepository: GetAppLanguageNameRepositoryInterface {
        
    init() {
        
    }
    
    func getLanguageName(languageCode: AppLanguageCodeDomainModel, translateInLanguageCode: AppLanguageCodeDomainModel) -> AppLanguageNameDomainModel {
        
        let languageName: String
        
        if let languageCodeDomainModel = LanguageCodeDomainModel(rawValue: languageCode) {
            
            switch languageCodeDomainModel {
            
            case .english:
                languageName = "English"
                
            case .french:
                languageName = "French"
                
            case .russian:
                languageName = "Russian"
                
            case .spanish:
                languageName = "Spanish"
            
            default:
                languageName = ""
            }
        }
        else {
            languageName = ""
        }
        
        return AppLanguageNameDomainModel(value: languageName)
    }
}
