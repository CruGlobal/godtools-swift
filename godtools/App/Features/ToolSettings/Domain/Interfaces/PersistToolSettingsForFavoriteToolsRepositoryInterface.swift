//
//  PersistToolSettingsForFavoriteToolsRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 5/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol PersistToolSettingsForFavoriteToolsRepositoryInterface {
    
    func persistToolSettingsForFavoriteToolPublisher(toolId: String, primaryLanguageId: String, parallelLanguageId: String?) -> AnyPublisher<Void, Never>
}
