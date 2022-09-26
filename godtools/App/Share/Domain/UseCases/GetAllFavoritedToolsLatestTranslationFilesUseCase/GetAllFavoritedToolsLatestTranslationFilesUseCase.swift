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
    
    private let getAllFavoritedResourceModelsUseCase: GetAllFavoritedResourceModelsUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let getDeviceLanguageUseCase: GetDeviceLanguageUseCase
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    
    private var cancellables = Set<AnyCancellable>()
    private var downloadLatestTranslationsCancellable: AnyCancellable?
    
    init(getAllFavoritedResourceModelsUseCase: GetAllFavoritedResourceModelsUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getDeviceLanguageUseCase: GetDeviceLanguageUseCase, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository) {
        
        self.getAllFavoritedResourceModelsUseCase = getAllFavoritedResourceModelsUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getDeviceLanguageUseCase = getDeviceLanguageUseCase
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
        
        Publishers.CombineLatest4(
            resourcesRepository.getResourcesChanged(),
            getAllFavoritedResourceModelsUseCase.getAllFavoritedResourceModelsPublisher(),
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
        
        let deviceLanguage: DeviceLanguageDomainModel = getDeviceLanguageUseCase.getDeviceLanguage()
        
        let languages: [LanguageDomainModel] = [deviceLanguage.language, primaryLanguage, parallelLanguage].compactMap({
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
