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
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    
    private var cancellables = Set<AnyCancellable>()
    private var downloadLatestTranslationsCancellable: AnyCancellable?
    
    init(getLanguageUseCase: GetLanguageUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, favoritedResourcesRepository: FavoritedResourcesRepository, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository) {
        
        self.getLanguageUseCase = getLanguageUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
        
        Publishers.CombineLatest3(
            resourcesRepository.getResourcesChanged(),
            favoritedResourcesRepository.getFavoritedResourcesChangedPublisher(),
            getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
        )
            .sink { [weak self] (resourcesChanged: Void, _, primaryLanguage: LanguageDomainModel?) in
                
                let favoritedTools = favoritedResourcesRepository.getFavoritedResourcesSortedByCreatedAt(ascendingOrder: false)
                
                self?.downloadLatestTranslationsForAllFavoritedTools(
                    favoritedTools: favoritedTools,
                    primaryLanguage: primaryLanguage
                )
            }
            .store(in: &cancellables)
    }
    
    private func downloadLatestTranslationsForAllFavoritedTools(favoritedTools: [FavoritedResourceDataModel], primaryLanguage: LanguageDomainModel?) {
              
        downloadLatestTranslationsCancellable?.cancel()
        
        let englishLanguage: LanguageDomainModel? = getLanguageUseCase.getLanguage(languageCode: LanguageCode.english.value)
        
        let languages: [LanguageDomainModel] = [englishLanguage, primaryLanguage].compactMap({
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
