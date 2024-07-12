//
//  GetLessonFilterLanguagesRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/12/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class GetLessonFilterLanguagesRepositoryTests: QuickSpec {
    
    override class func spec() {
        
        let getLessonFilterLanguagesRepository = GetLessonFilterLanguagesRepository(
            resourcesRepository: <#T##ResourcesRepository#>,
            languagesRepository: <#T##LanguagesRepository#>,
            getTranslatedLanguageName: <#T##GetTranslatedLanguageName#>,
            localizationServices: MockLocalizationServices(localizableStrings: [:])
        )
        
        describe("User is viewing the lessons language filter languages list.") {
         
            context("When my app language is spanish.") {
                
                let getOnboardingIsAvailable = GetOnboardingTutorialIsAvailable(
                    launchCountRepository: MockLaunchCountRepository(launchCount: 1),
                    onboardingTutorialViewedRepository: MockOnboardingTutorialViewedRepository(tutorialViewed: false)
                )

                it("I expect to see the language name translated in spanish.") {

                    var lessonLanguageFilterRef: LessonLanguageFilterDomainModel?
                    var sinkCompleted: Bool = false

                    waitUntil { done in

                        _ = getOnboardingIsAvailable
                            .isAvailablePublisher()
                            .sink { (lessonLanguageFilter: LessonLanguageFilterDomainModel?) in

                                guard !sinkCompleted else {
                                    return
                                }

                                sinkCompleted = true

                                lessonLanguageFilterRef = lessonLanguageFilter

                                done()
                            }

                    }

                    expect(lessonLanguageFilterRef?.translatedName).to(equal(true))
                }
            }
        }
    }
}
