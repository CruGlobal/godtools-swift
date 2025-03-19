//
//  GetTranslatedPercentageTests.swift
//  godtools
//
//  Created by Levi Eggert on 3/18/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Quick
import Nimble

class GetTranslatedPercentageTests: QuickSpec {
    
    override class func spec() {
                
        let englishLanguage = LanguageCodeDomainModel.english.rawValue
        
        describe("User is viewing a percentage value in the english language.") {
            
            let percentageValue: Double = 0.2449
            let expectedValue: String = "24%"
            
            context("When the percentage value is \(percentageValue)") {
                
                it("The percentage should round down to the nearest integer value.") {
                    
                    let getTranslatedPercentage = GetTranslatedPercentage()
                    
                    let percentageString = getTranslatedPercentage.getTranslatedPercentage(
                        percentValue: percentageValue,
                        translateInLanguage: englishLanguage
                    )
                                        
                    expect(percentageString).to(equal(expectedValue))
                }
            }
        }
        
        describe("User is viewing a percentage value in the english language.") {
            
            let percentageValue: Double = 0.001
            let expectedValue: String = "0%"
            
            context("When the percentage value is \(percentageValue)") {
                
                it("The percentage should round down to the nearest integer value.") {
                    
                    let getTranslatedPercentage = GetTranslatedPercentage()
                    
                    let percentageString = getTranslatedPercentage.getTranslatedPercentage(
                        percentValue: percentageValue,
                        translateInLanguage: englishLanguage
                    )
                                        
                    expect(percentageString).to(equal(expectedValue))
                }
            }
        }
        
        describe("User is viewing a percentage value in the english language.") {
            
            let percentageValue: Double = 0.0051
            let expectedValue: String = "1%"
            
            context("When the percentage value is \(percentageValue)") {
                
                it("The percentage should round up to the nearest integer value.") {
                    
                    let getTranslatedPercentage = GetTranslatedPercentage()
                    
                    let percentageString = getTranslatedPercentage.getTranslatedPercentage(
                        percentValue: percentageValue,
                        translateInLanguage: englishLanguage
                    )
                                        
                    expect(percentageString).to(equal(expectedValue))
                }
            }
        }
        
        describe("User is viewing a percentage value in the english language.") {
            
            let percentageValue: Double = 0.625000000001
            let expectedValue: String = "63%"
            
            context("When the percentage value is \(percentageValue)") {
                
                it("The percentage should round up to the nearest integer value.") {
                    
                    let getTranslatedPercentage = GetTranslatedPercentage()
                    
                    let percentageString = getTranslatedPercentage.getTranslatedPercentage(
                        percentValue: percentageValue,
                        translateInLanguage: englishLanguage
                    )
                                        
                    expect(percentageString).to(equal(expectedValue))
                }
            }
        }
        
        describe("User is viewing a percentage value in the english language.") {
            
            let percentageValue: Double = 0.8599911111111111
            let expectedValue: String = "86%"
            
            context("When the percentage value is \(percentageValue)") {
                
                it("The percentage should round up to the nearest integer value.") {
                    
                    let getTranslatedPercentage = GetTranslatedPercentage()
                    
                    let percentageString = getTranslatedPercentage.getTranslatedPercentage(
                        percentValue: percentageValue,
                        translateInLanguage: englishLanguage
                    )
                                        
                    expect(percentageString).to(equal(expectedValue))
                }
            }
        }
    }
}
