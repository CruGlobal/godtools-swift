//
//  DidChangeScaleForSpiritualConversationReadinessUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct DidChangeScaleForSpiritualConversationReadinessUseCaseTests {
    
    @Test(
        """
        Given: User is evaluating a lesson.
        When: Viewing the ready to share faith scale minimum and maximum values.
        Then: I expect the minimum value to be 1 and maximum value to be 10.
        """
    )
    func confirmReadinessScaleMinAndMaxValuesAreCorrect() {
        
        let didChangeSpiritualConversationReadinessScaleUseCase = getDidChangeScaleForSpiritualConversationReadinessUseCase()
        
        let readinessScale = didChangeSpiritualConversationReadinessScaleUseCase
            .execute(scale: 5, appLanguage: LanguageCodeDomainModel.english.rawValue)
                
        #expect(readinessScale.minScale.integerValue == 1)
        #expect(readinessScale.maxScale.integerValue == 10)
    }
    
    @Test(
        """
        Given: User is evaluating a lesson.
        When: Viewing the ready to share faith scale and my app language is english.
        Then: I expect the min, max, and scale values to be translated in my app language english.
        """
    )
    func readinessScaleIsTranslatedInEnglish() {
        
        let didChangeSpiritualConversationReadinessScaleUseCase = getDidChangeScaleForSpiritualConversationReadinessUseCase()
        
        let readinessScale = didChangeSpiritualConversationReadinessScaleUseCase
            .execute(scale: 5, appLanguage: LanguageCodeDomainModel.english.rawValue)
        
        #expect(readinessScale.minScale.valueTranslatedInAppLanguage == "1")
        #expect(readinessScale.maxScale.valueTranslatedInAppLanguage == "10")
        #expect(readinessScale.scale.valueTranslatedInAppLanguage == "5")
    }
    
    @Test(
        """
        Given: User is evaluating a lesson.
        When: Viewing the ready to share faith scale and my app language is arabic.
        Then: I expect the min, max, and scale values to be translated in my app language arabic.
        """
    )
    func readinessScaleIsTranslatedInArabic() {
        
        let didChangeSpiritualConversationReadinessScaleUseCase = getDidChangeScaleForSpiritualConversationReadinessUseCase()
        
        let readinessScale = didChangeSpiritualConversationReadinessScaleUseCase
            .execute(scale: 5, appLanguage: LanguageCodeDomainModel.arabic.rawValue)
        
        
        if #available(iOS 18, *) {
            
            #expect(readinessScale.minScale.valueTranslatedInAppLanguage == "1")
            #expect(readinessScale.maxScale.valueTranslatedInAppLanguage == "10")
            #expect(readinessScale.scale.valueTranslatedInAppLanguage == "5")
        }
        else {
            
            #expect(readinessScale.minScale.valueTranslatedInAppLanguage == "١")
            #expect(readinessScale.maxScale.valueTranslatedInAppLanguage == "١٠")
            #expect(readinessScale.scale.valueTranslatedInAppLanguage == "٥")
        }
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
    func readinessScaleIsClampedToMin(argument: TestClampingScale) {
        
        let didChangeSpiritualConversationReadinessScaleUseCase = getDidChangeScaleForSpiritualConversationReadinessUseCase()
        
        let readinessScale = didChangeSpiritualConversationReadinessScaleUseCase
            .execute(scale: argument.scaleValue, appLanguage: LanguageCodeDomainModel.english.rawValue)

        #expect(readinessScale.scale.integerValue == 1)
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
    func readinessScaleIsClampedToMax(argument: TestClampingScale) {
        
        let didChangeSpiritualConversationReadinessScaleUseCase = getDidChangeScaleForSpiritualConversationReadinessUseCase()
        
        let readinessScale = didChangeSpiritualConversationReadinessScaleUseCase
            .execute(scale: argument.scaleValue, appLanguage: LanguageCodeDomainModel.english.rawValue)
                
        #expect(readinessScale.scale.integerValue == 10)
    }
}

extension DidChangeScaleForSpiritualConversationReadinessUseCaseTests {
    
    private func getDidChangeScaleForSpiritualConversationReadinessUseCase() -> DidChangeScaleForSpiritualConversationReadinessUseCase {
        
        return DidChangeScaleForSpiritualConversationReadinessUseCase(
            getTranslatedNumberCount: GetTranslatedNumberCount()
        )
    }
}
