//
//  PersistUserToolLanguageSettingsRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 5/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol PersistUserToolLanguageSettingsRepositoryInterface {
    
    func persistUserToolLanguageSettingsPublisher(toolId: String, primaryLanguageId: String, parallelLanguageId: String?, selectedLanguageId: String) -> AnyPublisher<Bool, Never>
}
