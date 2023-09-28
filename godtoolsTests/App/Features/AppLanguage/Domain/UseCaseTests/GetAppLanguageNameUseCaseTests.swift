//
//  GetAppLanguageNameUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 9/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class GetAppLanguageNameUseCaseTests: QuickSpec {
    
    override class func spec() {
        
        describe("User is viewing the app languages list.") {
         
            context("When viewing the russian language name in it's own language.") {
                
                let getAppLanguageNameUseCase = GetAppLanguageNameUseCase(
                    getAppLanguageNameRepositoryInterface: GetAppLanguageNameRepository(localeLanguageName: LocaleLanguageName())
                )
                
                it("The language name for Russian should be translated in the Russian language.") {
                    
                    let languageName: AppLanguageNameDomainModel = getAppLanguageNameUseCase.getLanguageName(languageCode: LanguageCodeDomainModel.russian.value)
                    
                    expect(languageName.value).to(equal("русский"))
                }
            }
            
            context("When viewing the Czech language name in it's own language.") {
                
                let getAppLanguageNameUseCase = GetAppLanguageNameUseCase(
                    getAppLanguageNameRepositoryInterface: GetAppLanguageNameRepository(localeLanguageName: LocaleLanguageName())
                )
                
                it("The language name for Czech should be translated in the Czech language.") {
                    
                    let languageName: AppLanguageNameDomainModel = getAppLanguageNameUseCase.getLanguageName(languageCode: LanguageCodeDomainModel.czech.value)
                    
                    expect(languageName.value).to(equal("čeština"))
                }
            }
        }
    }
}
