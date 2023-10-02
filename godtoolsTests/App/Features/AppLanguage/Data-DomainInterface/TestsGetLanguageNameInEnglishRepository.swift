//
//  TestsGetLanguageNameInEnglishRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 9/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine

class TestsGetLanguageNameInEnglishRepository: GetAppLanguageNameRepositoryInterface {
        
    init() {
        
    }
    
    func getLanguageNamePublisher(appLanguageCode: AppLanguageCodeDomainModel, translateInLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<AppLanguageNameDomainModel, Never> {
        
        let languageName: String
        
        if let languageCodeDomainModel = LanguageCodeDomainModel(rawValue: appLanguageCode) {
            
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
        
        return Just(AppLanguageNameDomainModel(value: languageName))
            .eraseToAnyPublisher()
    }
}
