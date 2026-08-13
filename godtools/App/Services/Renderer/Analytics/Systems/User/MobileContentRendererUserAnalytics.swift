//
//  MobileContentRendererUserAnalytics.swift
//  godtools
//
//  Created by Rachael Skeath on 2/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class MobileContentRendererUserAnalytics {
    
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
    private let maxAllowedLessonCompletionIncrementsPerSession: Int = 1
    
    private var cancellables = Set<AnyCancellable>()
    private var trackLessonCompletionsCount: Int = 0
    
    init(incrementUserCounterUseCase: IncrementUserCounterUseCase) {

        self.incrementUserCounterUseCase = incrementUserCounterUseCase
    }
}

extension MobileContentRendererUserAnalytics: MobileContentRendererAnalyticsSystem {
    
    private static let lessonCompletionsActionPrefix = "lesson_completions"
    
    func trackMobileContentAction(
        screenName: String,
        siteSection: String,
        appLanguage: AppLanguageDomainModel,
        contentLanguage: BCP47LanguageIdentifier,
        secondaryContentLanguage: BCP47LanguageIdentifier?,
        action: String,
        data: [String: Any]?
    ) {
        
        guard action.hasPrefix(MobileContentRendererUserAnalytics.lessonCompletionsActionPrefix) else {
            return
        }
        
        if trackLessonCompletionsCount < maxAllowedLessonCompletionIncrementsPerSession || maxAllowedLessonCompletionIncrementsPerSession == 0 {
                        
            incrementUserCounterUseCase
                .execute(
                    interaction: .lessonCompletion(mobileContentAction: action)
                )
                .sink { _ in
                    
                } receiveValue: { _ in
                    
                }
                .store(in: &Self.backgroundCancellables)
        }
        
        trackLessonCompletionsCount += 1
    }
}
