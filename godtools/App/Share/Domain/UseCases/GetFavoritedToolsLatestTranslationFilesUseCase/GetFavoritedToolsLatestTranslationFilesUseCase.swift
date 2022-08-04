//
//  GetFavoritedToolsLatestTranslationFilesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/2/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetFavoritedToolsLatestTranslationFilesUseCase {
        
    private static var cancellables = Set<AnyCancellable>()

    private let resourcesRepository: ResourcesRepository
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let translationsRepository: TranslationsRepository
    
    init(resourcesRepository: ResourcesRepository, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, translationsRepository: TranslationsRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.translationsRepository = translationsRepository
    }
    
    func getLatestTranslationFiles(for favoritedTools: [FavoritedResourceModel]) {
                     
        let languages: [LanguageDomainModel] = [getSettingsPrimaryLanguageUseCase.getPrimaryLanguage(), getSettingsParallelLanguageUseCase.getParallelLanguage()].compactMap({
            return $0
        })
        
        guard !favoritedTools.isEmpty && !languages.isEmpty else {
            return
        }
       
        var translations: [TranslationModel] = Array()
        
        for tool in favoritedTools {
            
            for language in languages {
                
                guard let translation = resourcesRepository.getResourceLanguageLatestTranslation(resourceId: tool.resourceId, languageId: language.dataModelId) else {
                    continue
                }
                
                translations.append(translation)
            }
        }
                
        var cancellable: AnyCancellable?
        
        cancellable = translationsRepository.downloadAndCacheTranslationsFiles(translations: translations)
            .sink { completed in
                if let cancellable = cancellable {
                    GetFavoritedToolsLatestTranslationFilesUseCase.cancellables.remove(cancellable)
                }
            } receiveValue: { (files: [TranslationFilesDataModel]) in

            }
        
        if let cancellable = cancellable {
            GetFavoritedToolsLatestTranslationFilesUseCase.cancellables.update(with: cancellable)
        }
    }
}
