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
    
    func trackMobileContentAction(screenName: String, siteSection: String, action: String, data: [String : Any]?) {

        guard action.hasPrefix(MobileContentRendererUserAnalytics.lessonCompletionsActionPrefix) else {
            return
        }
        
        if trackLessonCompletionsCount < maxAllowedLessonCompletionIncrementsPerSession || maxAllowedLessonCompletionIncrementsPerSession == 0 {
                        
            incrementUserCounterUseCase.incrementUserCounter(for: .lessonCompletion(mobileContentAction: action))
                .sink { _ in
                    
                } receiveValue: { _ in
                    
                }
                .store(in: &cancellables)
        }
        
        trackLessonCompletionsCount += 1
    }
}
