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
    
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    
    private var cancellables = Set<AnyCancellable>()
    private var downloadLatestTranslationsCancellable: AnyCancellable?
    
    init(getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, favoritedResourcesRepository: FavoritedResourcesRepository, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository) {
        
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
        
        Publishers.CombineLatest4(
            resourcesRepository.getResourcesChanged(),
            favoritedResourcesRepository.getFavoritedResourcesChanged(),
            getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher(),
            getSettingsParallelLanguageUseCase.getParallelLanguagePublisher())
            .sink { [weak self] (resourcesChanged: Void, _, primaryLanguage: LanguageDomainModel?, parallelLanguage: LanguageDomainModel?) in
                
                let favoritedTools = favoritedResourcesRepository.getFavoritedResourcesSortedByCreatedAt(ascendingOrder: false)
                
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
