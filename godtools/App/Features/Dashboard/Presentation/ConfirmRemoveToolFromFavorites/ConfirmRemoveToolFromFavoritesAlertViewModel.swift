//
//  ConfirmRemoveToolFromFavoritesAlertViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ConfirmRemoveToolFromFavoritesAlertViewModel: AlertMessageViewModelType {
    
    private static var removeToolFromFavoritesCancellable: AnyCancellable?
    
    private let tool: ToolDomainModel
    private let translationsRepository: TranslationsRepository
    private let localizationServices: LocalizationServices
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase
    
    let title: String?
    let message: String?
    let cancelTitle: String?
    let acceptTitle: String
    
    init(tool: ToolDomainModel, translationsRepository: TranslationsRepository, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase) {
        
        self.tool = tool
        self.translationsRepository = translationsRepository
        self.localizationServices = localizationServices
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.removeToolFromFavoritesUseCase = removeToolFromFavoritesUseCase
        
        let settingsPrimaryLanguage: LanguageDomainModel? = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()
        
        let toolName: String
        
        if let settingsPrimaryLanguage = settingsPrimaryLanguage, let primaryTranslation = translationsRepository.getLatestTranslation(resourceId: tool.dataModelId, languageId: settingsPrimaryLanguage.dataModelId) {
            toolName = primaryTranslation.translatedName
        }
        else if let englishTranslation = translationsRepository.getLatestTranslation(resourceId: tool.dataModelId, languageCode: LanguageCodes.english) {
            toolName = englishTranslation.translatedName
        }
        else {
            toolName = tool.name
        }
        
        title = localizationServices.stringForSystemElseEnglish(key: "remove_from_favorites_title")
        message = localizationServices.stringForSystemElseEnglish(key: "remove_from_favorites_message").replacingOccurrences(of: "%@", with: toolName)
        acceptTitle = localizationServices.stringForSystemElseEnglish(key: "yes")
        cancelTitle = localizationServices.stringForSystemElseEnglish(key: "no")
    }
    
    func acceptTapped() {
        
        ConfirmRemoveToolFromFavoritesAlertViewModel.removeToolFromFavoritesCancellable = removeToolFromFavoritesUseCase.removeToolFromFavoritesPublisher(id: tool.dataModelId)
            .sink { _ in
                
            }
    }
}
