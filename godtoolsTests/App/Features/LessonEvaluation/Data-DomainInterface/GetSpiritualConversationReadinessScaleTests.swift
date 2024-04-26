//
//  GetSpiritualConversationReadinessScaleTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class GetSpiritualConversationReadinessScaleTests: QuickSpec {
    
    override class func spec() {
        
        describe("User is evaluating a lesson.") {
        
            context("When viewing the ready to share faith scale minimum value.") {
            
                let getSpiritualConversationReadinessScale = GetSpiritualConversationReadinessScale(
                    getTranslatedNumberCount: GetTranslatedNumberCount()
                )
                
                it("I expect the minimum value to be 1 and maximum value to be 10.") {
                                        
                    var readinessScaleRef: SpiritualConversationReadinessScaleDomainModel?
                    
                    var sinkCount: Int = 0
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = getSpiritualConversationReadinessScale
                            .getScalePublisher(scale: 5, translateInAppLanguage: LanguageCodeDomainModel.english.rawValue)
                            .sink { (readinessScale: SpiritualConversationReadinessScaleDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCount += 1
                                
                                if sinkCount == 1 {
                                    
                                    readinessScaleRef = readinessScale
                                    
                                    sinkCompleted = true
                                    
                                    done()
                                }
                            }
                    }

                    expect(readinessScaleRef?.minScale.integerValue).to(equal(1))
                    expect(readinessScaleRef?.maxScale.integerValue).to(equal(10))
                }
            }
            
            context("When viewing the ready to share faith scale in english.") {
            
                let getSpiritualConversationReadinessScale = GetSpiritualConversationReadinessScale(
                    getTranslatedNumberCount: GetTranslatedNumberCount()
                )
                
                it("I expect the min, max, and scale values to be translated in english.") {
                    
                    var readinessScaleRef: SpiritualConversationReadinessScaleDomainModel?
                    
                    var sinkCount: Int = 0
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = getSpiritualConversationReadinessScale
                            .getScalePublisher(scale: 5, translateInAppLanguage: LanguageCodeDomainModel.english.rawValue)
                            .sink { (readinessScale: SpiritualConversationReadinessScaleDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCount += 1
                                
                                if sinkCount == 1 {
                                    
                                    readinessScaleRef = readinessScale
                                    
                                    sinkCompleted = true
                                    
                                    done()
                                }
                            }
                    }

                    expect(readinessScaleRef?.minScale.valueTranslatedInAppLanguage).to(equal("1"))
                    expect(readinessScaleRef?.maxScale.valueTranslatedInAppLanguage).to(equal("10"))
                    expect(readinessScaleRef?.scale.valueTranslatedInAppLanguage).to(equal("5"))
                }
            }
            
            context("When viewing the ready to share faith scale in arabic.") {
            
                let getSpiritualConversationReadinessScale = GetSpiritualConversationReadinessScale(
                    getTranslatedNumberCount: GetTranslatedNumberCount()
                )
                
                it("I expect the min, max, and scale values to be translated in arabic.") {
                    
                    var readinessScaleRef: SpiritualConversationReadinessScaleDomainModel?
                    
                    var sinkCount: Int = 0
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = getSpiritualConversationReadinessScale
                            .getScalePublisher(scale: 5, translateInAppLanguage: LanguageCodeDomainModel.arabic.rawValue)
                            .sink { (readinessScale: SpiritualConversationReadinessScaleDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCount += 1
                                
                                if sinkCount == 1 {
                                    
                                    readinessScaleRef = readinessScale
                                    
                                    sinkCompleted = true
                                    
                                    done()
                                }
                            }
                    }

                    expect(readinessScaleRef?.minScale.valueTranslatedInAppLanguage).to(equal("١"))
                    expect(readinessScaleRef?.maxScale.valueTranslatedInAppLanguage).to(equal("١٠"))
                    expect(readinessScaleRef?.scale.valueTranslatedInAppLanguage).to(equal("٥"))
                }
            }
            
            context("When providing a scale value that is lower than the minimum 1.") {
            
                let getSpiritualConversationReadinessScale = GetSpiritualConversationReadinessScale(
                    getTranslatedNumberCount: GetTranslatedNumberCount()
                )
                
                it("I expect the scale value to equal the minimum scale value 1.") {
                    
                    var readinessScaleRef: SpiritualConversationReadinessScaleDomainModel?
                    
                    var sinkCount: Int = 0
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = getSpiritualConversationReadinessScale
                            .getScalePublisher(scale: -10, translateInAppLanguage: LanguageCodeDomainModel.english.rawValue)
                            .sink { (readinessScale: SpiritualConversationReadinessScaleDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCount += 1
                                
                                if sinkCount == 1 {
                                    
                                    readinessScaleRef = readinessScale
                                    
                                    sinkCompleted = true
                                    
                                    done()
                                }
                            }
                    }

                    expect(readinessScaleRef?.scale.integerValue).to(equal(1))
                    expect(readinessScaleRef?.scale.valueTranslatedInAppLanguage).to(equal("1"))
                }
            }
            
            context("When providing a scale value that is greater than the maximum 10.") {
            
                let getSpiritualConversationReadinessScale = GetSpiritualConversationReadinessScale(
                    getTranslatedNumberCount: GetTranslatedNumberCount()
                )
                
                it("I expect the scale value to equal the maximum scale value 10.") {
                    
                    var readinessScaleRef: SpiritualConversationReadinessScaleDomainModel?
                    
                    var sinkCount: Int = 0
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = getSpiritualConversationReadinessScale
                            .getScalePublisher(scale: 99999, translateInAppLanguage: LanguageCodeDomainModel.english.rawValue)
                            .sink { (readinessScale: SpiritualConversationReadinessScaleDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCount += 1
                                
                                if sinkCount == 1 {
                                    
                                    readinessScaleRef = readinessScale
                                    
                                    sinkCompleted = true
                                    
                                    done()
                                }
                            }
                    }

                    expect(readinessScaleRef?.scale.integerValue).to(equal(10))
                    expect(readinessScaleRef?.scale.valueTranslatedInAppLanguage).to(equal("10"))
                }
            }
        }
    }
}
