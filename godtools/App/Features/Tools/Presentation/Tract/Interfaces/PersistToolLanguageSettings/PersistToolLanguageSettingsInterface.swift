//
//  PersistToolLanguageSettingsInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 4/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

protocol PersistToolLanguageSettingsInterface {
    
    func persistToolLanguageSettingsPublisher(with toolId: String, primaryLanguageId: String, parallelLanguageId: String?) -> AnyPublisher<Bool, Never>
}
