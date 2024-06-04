//
//  PersistToolSettingsIfFavoriteToolRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 5/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol PersistToolSettingsIfFavoriteToolRepositoryInterface {
    
    func persistToolSettingsIfFavoriteToolPublisher(toolId: String, primaryLanguageId: String, parallelLanguageId: String?) -> AnyPublisher<Bool, Never>
}
