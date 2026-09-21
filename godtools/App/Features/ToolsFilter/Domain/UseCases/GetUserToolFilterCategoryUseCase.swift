//
//  GetUserToolFilterCategoryUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetUserToolFilterCategoryUseCase: Sendable {
    
    private let userToolFilterSettingsRepository: UserToolFilterSettingsRepository
    private let getToolFilterCategory: GetToolFilterCategory
    
    init(userToolFilterSettingsRepository: UserToolFilterSettingsRepository, getToolFilterCategory: GetToolFilterCategory) {
        
        self.userToolFilterSettingsRepository = userToolFilterSettingsRepository
        self.getToolFilterCategory = getToolFilterCategory
    }
    
    @MainActor func execute(
        appLanguage: AppLanguageDomainModel
    ) -> AnyPublisher<ToolFilterCategoryDomainModel, Never> {
        
        return userToolFilterSettingsRepository
            .observeSettingValueChangedPublisher(settingType: .toolsCategoryFilter)
            .receive(on: DispatchQueue.global())
            .map { (categoryId: String?) in
                return self.getToolFilterCategory(categoryId: categoryId, appLanguage: appLanguage)
            }
            .eraseToAnyPublisher()
    }
    
    private func getToolFilterCategory(categoryId: String?, appLanguage: AppLanguageDomainModel) -> ToolFilterCategoryDomainModel {
        
        if let categoryId = categoryId {
            
            return getToolFilterCategory.getCategoryFilter(
                categoryId: categoryId,
                translatedInAppLanguage: appLanguage
            )
        }
        
        return getToolFilterCategory.getAnyCategoryFilter(translatedInAppLanguage: appLanguage)
    }
}
