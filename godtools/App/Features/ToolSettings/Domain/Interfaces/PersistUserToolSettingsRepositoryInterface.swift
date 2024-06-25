//
//  PersistUserToolSettingsRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 5/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol PersistUserToolSettingsRepositoryInterface {
    
    func persistUserToolSettingsPublisher(toolId: String, primaryLanguageId: String, parallelLanguageId: String?, selectedLanguageId: String) -> AnyPublisher<Bool, Never>
}
