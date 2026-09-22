//
//  SelectedToolFilterCategoryUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class SelectedToolFilterCategoryUseCase: Sendable {
    
    private let userToolFilterSettingsRepository: UserToolFilterSettingsRepository
    
    init(userToolFilterSettingsRepository: UserToolFilterSettingsRepository) {
        
        self.userToolFilterSettingsRepository = userToolFilterSettingsRepository
    }
    
    func execute(category: ToolFilterCategoryDomainModel) async throws {
        
        let categoryId: String? = category.categoryType != .any ? category.id : nil
        
        try await userToolFilterSettingsRepository.storeSettingValue(
            settingType: .toolsCategoryFilter,
            value: categoryId
        )
    }
}
