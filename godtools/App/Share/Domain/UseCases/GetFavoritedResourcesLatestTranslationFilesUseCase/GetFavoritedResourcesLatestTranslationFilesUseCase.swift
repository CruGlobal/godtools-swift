//
//  GetFavoritedResourcesLatestTranslationFilesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/2/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetFavoritedResourcesLatestTranslationFilesUseCase {
        
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
    
    func getLatestTranslationFiles(for favoritedResources: [FavoritedResourceModel]) {
                     
        let languages: [LanguageDomainModel] = [getSettingsPrimaryLanguageUseCase.getPrimaryLanguage(), getSettingsParallelLanguageUseCase.getParallelLanguage()].compactMap({
            return $0
        })
        
        guard !favoritedResources.isEmpty && !languages.isEmpty else {
            return
        }
       
        var translations: [TranslationModel] = Array()
        
        for favoritedResource in favoritedResources {
            
            for language in languages {
                
                guard let translation = resourcesRepository.getResourceLanguageLatestTranslation(resourceId: favoritedResource.resourceId, languageId: language.dataModelId) else {
                    continue
                }
                
                translations.append(translation)
            }
        }
                
        var cancellable: AnyCancellable?
        
        cancellable = translationsRepository.downloadAndCacheTranslationsFiles(translations: translations)
            .sink { completed in
                if let cancellable = cancellable {
                    GetFavoritedResourcesLatestTranslationFilesUseCase.cancellables.remove(cancellable)
                }
            } receiveValue: { (files: [TranslationFilesDataModel]) in

            }
        
        if let cancellable = cancellable {
            GetFavoritedResourcesLatestTranslationFilesUseCase.cancellables.update(with: cancellable)
        }
    }
}
