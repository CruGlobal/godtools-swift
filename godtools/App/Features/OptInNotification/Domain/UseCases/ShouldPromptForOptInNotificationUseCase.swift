//
//  ShouldPromptForOptInNotificationUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 4/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class ShouldPromptForOptInNotificationUseCase {
    
    private let shouldPromptForOptInNotification: ShouldPromptForOptInNotificationInterface
    
    init(shouldPromptForOptInNotification: ShouldPromptForOptInNotificationInterface) {
        
        self.shouldPromptForOptInNotification = shouldPromptForOptInNotification
    }
    
    func shouldPromptPublisher() -> AnyPublisher<Bool, Never> {
        
        return shouldPromptForOptInNotification
            .shouldPromptPublisher()
    }
}
