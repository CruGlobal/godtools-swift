//
//  ShouldPromptForOptInNotificationInterface.swift
//  godtools
//
//  Created by Levi Eggert on 4/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

protocol ShouldPromptForOptInNotificationInterface {
    
    func shouldPromptPublisher() -> AnyPublisher<Bool, Never>
}
