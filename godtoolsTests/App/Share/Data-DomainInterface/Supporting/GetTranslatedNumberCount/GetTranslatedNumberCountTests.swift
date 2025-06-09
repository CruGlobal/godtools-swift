//
//  GetTranslatedNumberCountTests.swift
//  godtools
//
//  Created by Levi Eggert on 6/2/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Quick
import Nimble

class GetTranslatedNumberCountTests: QuickSpec {
    
    override class func spec() {
                        
        describe("User is viewing an integer value.") {
            
            let integerValue: Int = 1
            
            context("When the value is \(integerValue) and language is english") {
                
                let expectedValue: String = "1"
                
                it("The value should display as \(expectedValue).") {
                    
                    let getTranslatedNumberCount = GetTranslatedNumberCount()
                    
                    let translation: String = getTranslatedNumberCount.getTranslatedCount(
                        count: integerValue,
                        translateInLanguage: LanguageCodeDomainModel.english.rawValue
                    )
                 
                    expect(translation).to(equal(expectedValue))
                }
            }
        }
    }
}
