//
//  GetUserLessonFiltersRepositoryTests.swift
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

class GetUserLessonFiltersRepositoryTests: QuickSpec {
    
    override class func spec() {
        
        describe("User is viewing lessons.") {
         
            context("When a lesson language filter hasn't been chosen by the user.") {
                
//                let getOnboardingIsAvailable = GetOnboardingTutorialIsAvailable(
//                    launchCountRepository: MockLaunchCountRepository(launchCount: 1),
//                    onboardingTutorialViewedRepository: MockOnboardingTutorialViewedRepository(tutorialViewed: false)
//                )
//                
//                it("The lesson language filter should default to the current app language.") {
//                    
//                    var lessonLanguageFilterRef: LessonLanguageFilterDomainModel?
//                    var sinkCompleted: Bool = false
//                    
//                    waitUntil { done in
//                        
//                        _ = getOnboardingIsAvailable
//                            .isAvailablePublisher()
//                            .sink { (lessonLanguageFilter: LessonLanguageFilterDomainModel?) in
//                                
//                                guard !sinkCompleted else {
//                                    return
//                                }
//                                
//                                sinkCompleted = true
//                                
//                                lessonLanguageFilterRef = lessonLanguageFilter
//                                
//                                done()
//                            }
//                        
//                    }
//                    
//                    expect(lessonLanguageFilterRef?.translatedName).to(equal(true))
//                }
            }
        }
    }
}
