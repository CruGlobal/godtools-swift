//
//  GetAllFavoritedToolsLatestTranslationFilesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/3/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAllFavoritedToolsLatestTranslationFilesUseCase {
    
    private let getAllFavoritedToolIDsUseCase: GetAllFavoritedToolIDsUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    
    private var cancellables = Set<AnyCancellable>()
    private var downloadLatestTranslationsCancellable: AnyCancellable?
    
    init(getAllFavoritedToolIDsUseCase: GetAllFavoritedToolIDsUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository) {
        
        self.getAllFavoritedToolIDsUseCase = getAllFavoritedToolIDsUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
        
        Publishers.CombineLatest4(
            resourcesRepository.getResourcesChanged(),
            getAllFavoritedToolIDsUseCase.getAllFavoritedToolIDsPublisher(),
            getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher(),
            getSettingsParallelLanguageUseCase.getParallelLanguagePublisher())
            .sink { [weak self] (resourcesChanged: Void, favoritedTools: [FavoritedResourceModel], primaryLanguage: LanguageDomainModel?, parallelLanguage: LanguageDomainModel?) in
                
                self?.downloadLatestTranslationsForAllFavoritedTools(
                    favoritedTools: favoritedTools,
                    primaryLanguage: primaryLanguage,
                    parallelLanguage: parallelLanguage
                )
            }
            .store(in: &cancellables)
    }
    
    private func downloadLatestTranslationsForAllFavoritedTools(favoritedTools: [FavoritedResourceModel], primaryLanguage: LanguageDomainModel?, parallelLanguage: LanguageDomainModel?) {
              
        downloadLatestTranslationsCancellable?.cancel()
        
        let languages: [LanguageDomainModel] = [primaryLanguage, parallelLanguage].compactMap({
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
                        
        downloadLatestTranslationsCancellable = translationsRepository.downloadAndCacheTranslationsFiles(translations: translations)
            .sink { completed in
                print(completed)
            } receiveValue: { (files: [TranslationFilesDataModel]) in

            }
    }
}
