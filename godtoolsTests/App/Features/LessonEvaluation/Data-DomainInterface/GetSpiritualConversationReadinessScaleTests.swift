//
//  GetSpiritualConversationReadinessScaleTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct GetSpiritualConversationReadinessScaleTests {
    
    @Test(
        """
        Given: User is evaluating a lesson.
        When: Viewing the ready to share faith scale minimum and maximum values.
        Then: I expect the minimum value to be 1 and maximum value to be 10.
        """
    )
    @MainActor func confirmReadinessScaleMinAndMaxValuesAreCorrect() async {
        
        let getSpiritualConversationReadinessScale = GetSpiritualConversationReadinessScale(
            getTranslatedNumberCount: GetTranslatedNumberCount()
        )
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var readinessScaleRef: SpiritualConversationReadinessScaleDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            getSpiritualConversationReadinessScale
                .getScalePublisher(scale: 5, translateInAppLanguage: LanguageCodeDomainModel.english.rawValue)
                .sink { (readinessScale: SpiritualConversationReadinessScaleDomainModel) in
                    
                    readinessScaleRef = readinessScale
                    
                    confirmation()
                }
                .store(in: &cancellables)
        }
        
        #expect(readinessScaleRef?.minScale.integerValue == 1)
        #expect(readinessScaleRef?.maxScale.integerValue == 10)
    }
    
    @Test(
        """
        Given: User is evaluating a lesson.
        When: Viewing the ready to share faith scale and my app language is english.
        Then: I expect the min, max, and scale values to be translated in my app language english.
        """
    )
    @MainActor func readinessScaleIsTranslatedInEnglish() async {
        
        let getSpiritualConversationReadinessScale = GetSpiritualConversationReadinessScale(
            getTranslatedNumberCount: GetTranslatedNumberCount()
        )
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var readinessScaleRef: SpiritualConversationReadinessScaleDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            getSpiritualConversationReadinessScale
                .getScalePublisher(scale: 5, translateInAppLanguage: LanguageCodeDomainModel.english.rawValue)
                .sink { (readinessScale: SpiritualConversationReadinessScaleDomainModel) in
                    
                    readinessScaleRef = readinessScale
                    
                    confirmation()
                }
                .store(in: &cancellables)
        }
        
        #expect(readinessScaleRef?.minScale.valueTranslatedInAppLanguage == "1")
        #expect(readinessScaleRef?.maxScale.valueTranslatedInAppLanguage == "10")
        #expect(readinessScaleRef?.scale.valueTranslatedInAppLanguage == "5")
    }
    
    @Test(
        """
        Given: User is evaluating a lesson.
        When: Viewing the ready to share faith scale and my app language is arabic.
        Then: I expect the min, max, and scale values to be translated in my app language arabic.
        """
    )
    @MainActor func readinessScaleIsTranslatedInArabic() async {
        
        let getSpiritualConversationReadinessScale = GetSpiritualConversationReadinessScale(
            getTranslatedNumberCount: GetTranslatedNumberCount()
        )
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var readinessScaleRef: SpiritualConversationReadinessScaleDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            getSpiritualConversationReadinessScale
                .getScalePublisher(scale: 5, translateInAppLanguage: LanguageCodeDomainModel.arabic.rawValue)
                .sink { (readinessScale: SpiritualConversationReadinessScaleDomainModel) in
                    
                    readinessScaleRef = readinessScale
                    
                    confirmation()
                }
                .store(in: &cancellables)
        }
        
        if #available(iOS 18, *) {
            
            #expect(readinessScaleRef?.minScale.valueTranslatedInAppLanguage == "1")
            #expect(readinessScaleRef?.maxScale.valueTranslatedInAppLanguage == "10")
            #expect(readinessScaleRef?.scale.valueTranslatedInAppLanguage == "5")
        }
        else {
            
            #expect(readinessScaleRef?.minScale.valueTranslatedInAppLanguage == "١")
            #expect(readinessScaleRef?.maxScale.valueTranslatedInAppLanguage == "١٠")
            #expect(readinessScaleRef?.scale.valueTranslatedInAppLanguage == "٥")
        }
    }
    
    @Test(
        """
        Given: User is evaluating a lesson.
        When: Viewing the ready to share faith scale and my app language is eastern arabic.
        Then: I expect the min, max, and scale values to be translated in my app language eastern arabic.
        """
    )
    @MainActor func readinessScaleIsTranslatedInEasternArabic() async {
        
        let getSpiritualConversationReadinessScale = GetSpiritualConversationReadinessScale(
            getTranslatedNumberCount: GetTranslatedNumberCount()
        )
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var readinessScaleRef: SpiritualConversationReadinessScaleDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            getSpiritualConversationReadinessScale
                .getScalePublisher(scale: 5, translateInAppLanguage: "ar_SA")
                .sink { (readinessScale: SpiritualConversationReadinessScaleDomainModel) in
                    
                    readinessScaleRef = readinessScale
                    
                    confirmation()
                }
                .store(in: &cancellables)
        }
        
        #expect(readinessScaleRef?.minScale.valueTranslatedInAppLanguage == "١")
        #expect(readinessScaleRef?.maxScale.valueTranslatedInAppLanguage == "١٠")
        #expect(readinessScaleRef?.scale.valueTranslatedInAppLanguage == "٥")
    }
    
    struct TestClampingScale {
        
        let scaleValue: Int
    }
    
    @Test(
        """
        Given: User is evaluating a lesson.
        When: Providing a scale value that is lower than the minimum 1.
        Then: I expect the scale value to equal the minimum scale value 1.
        """,
        arguments: [
            TestClampingScale(scaleValue: 0),
            TestClampingScale(scaleValue: -10)
        ]
    )
    @MainActor func readinessScaleIsClampedToMin(argument: TestClampingScale) async {
        
        let getSpiritualConversationReadinessScale = GetSpiritualConversationReadinessScale(
            getTranslatedNumberCount: GetTranslatedNumberCount()
        )
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var readinessScaleRef: SpiritualConversationReadinessScaleDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            getSpiritualConversationReadinessScale
                .getScalePublisher(scale: argument.scaleValue, translateInAppLanguage: LanguageCodeDomainModel.english.rawValue)
                .sink { (readinessScale: SpiritualConversationReadinessScaleDomainModel) in
                    
                    readinessScaleRef = readinessScale
                    
                    confirmation()
                }
                .store(in: &cancellables)
        }
        
        #expect(readinessScaleRef?.scale.integerValue == 1)
    }
    
    @Test(
        """
        Given: User is evaluating a lesson.
        When: Providing a scale value that is greater than the maximum 10.
        Then: I expect the scale value to equal the maximum scale value 10.
        """,
        arguments: [
            TestClampingScale(scaleValue: 11),
            TestClampingScale(scaleValue: 99999)
        ]
    )
    @MainActor func readinessScaleIsClampedToMax(argument: TestClampingScale) async {
        
        let getSpiritualConversationReadinessScale = GetSpiritualConversationReadinessScale(
            getTranslatedNumberCount: GetTranslatedNumberCount()
        )
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var readinessScaleRef: SpiritualConversationReadinessScaleDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            getSpiritualConversationReadinessScale
                .getScalePublisher(scale: argument.scaleValue, translateInAppLanguage: LanguageCodeDomainModel.english.rawValue)
                .sink { (readinessScale: SpiritualConversationReadinessScaleDomainModel) in
                    
                    readinessScaleRef = readinessScale
                    
                    confirmation()
                }
                .store(in: &cancellables)
        }
        
        #expect(readinessScaleRef?.scale.integerValue == 10)
    }
}
