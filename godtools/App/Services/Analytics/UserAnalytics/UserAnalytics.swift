//
//  UserAnalytics.swift
//  godtools
//
//  Created by Rachael Skeath on 2/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class UserAnalytics {
    
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
    init(incrementUserCounterUseCase: IncrementUserCounterUseCase) {

        self.incrementUserCounterUseCase = incrementUserCounterUseCase
    }
}

extension UserAnalytics: MobileContentAnalyticsSystem {
    
    private static let lessonCompletionsActionPrefix = "lesson_completions"
    
    func trackMobileContentAction(screenName: String, siteSection: String, action: String, data: [String : Any]?) {

        guard action.hasPrefix(UserAnalytics.lessonCompletionsActionPrefix) else { return }
        
        incrementUserCounterUseCase.incrementUserCounter(for: .lessonCompletion(mobileContentAction: action))
            .sink { _ in
                
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
}
