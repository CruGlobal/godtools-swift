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
    
    private let getLanguageUseCase: GetLanguageUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    
    private var cancellables = Set<AnyCancellable>()
    private var downloadLatestTranslationsCancellable: AnyCancellable?
    
    init(getLanguageUseCase: GetLanguageUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, favoritedResourcesRepository: FavoritedResourcesRepository, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository) {
        
        self.getLanguageUseCase = getLanguageUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
        
        Publishers.CombineLatest4(
            resourcesRepository.getResourcesChanged(),
            favoritedResourcesRepository.getFavoritedResourcesChangedPublisher(),
            getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher(),
            getSettingsParallelLanguageUseCase.getParallelLanguagePublisher()
        )
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
    
    private func downloadLatestTranslationsForAllFavoritedTools(favoritedTools: [FavoritedResourceDataModel], primaryLanguage: LanguageDomainModel?, parallelLanguage: LanguageDomainModel?) {
              
        downloadLatestTranslationsCancellable?.cancel()
        
        let englishLanguage: LanguageDomainModel? = getLanguageUseCase.getLanguage(languageCode: LanguageCode.english.value)
        
        let languages: [LanguageDomainModel] = [englishLanguage, primaryLanguage, parallelLanguage].compactMap({
            return $0
        })
        
        guard !favoritedTools.isEmpty && !languages.isEmpty else {
            return
        }
       
        var translations: [TranslationModel] = Array()
        
        for favoritedTool in favoritedTools {
            
            for language in languages {
                
                guard let translation = translationsRepository.getLatestTranslation(resourceId: favoritedTool.id, languageId: language.dataModelId) else {
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
