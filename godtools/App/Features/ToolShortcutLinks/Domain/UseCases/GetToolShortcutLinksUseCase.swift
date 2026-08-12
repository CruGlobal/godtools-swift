//
//  GetToolShortcutLinksUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolShortcutLinksUseCase: Sendable {

    private static let appDeepLinkBaseUrlString: String = "godtools://knowgod.com"
    private static let toolDeepLinkPageNumber: Int = 0

    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    private let maxNumberOfToolShortcutLinks: Int = 4
    
    init(
        favoritedResourcesRepository: FavoritedResourcesRepository,
        resourcesRepository: ResourcesRepository,
        translationsRepository: TranslationsRepository
    ) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[ToolShortcutLinkDomainModel], Error> {
        
        return favoritedResourcesRepository
            .observeCollectionChangesPublisher()
            .receive(on: DispatchQueue.global())
            .flatMap { (favoritesChanged: Void) -> AnyPublisher<[ToolShortcutLinkDomainModel], Error> in
                
                return AnyPublisher() {
                    try await self.asyncExecute(appLanguage: appLanguage)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func asyncExecute(appLanguage: AppLanguageDomainModel) async throws -> [ToolShortcutLinkDomainModel] {
        
        let favoritedResources: [FavoritedResourceDataModel] = try await favoritedResourcesRepository.getFavoritedResourcesSortedByPosition()
        
        return getToolShortcutLinks(
            appLanguage: appLanguage,
            favoritedResources: favoritedResources
        )
    }
    
    private func getToolShortcutLinks(appLanguage: AppLanguageDomainModel, favoritedResources: [FavoritedResourceDataModel]) -> [ToolShortcutLinkDomainModel] {
        
        let toolShortcutLinks: [ToolShortcutLinkDomainModel] = favoritedResources
            .prefix(self.maxNumberOfToolShortcutLinks)
            .compactMap { (favoritedResource: FavoritedResourceDataModel) in
                
                guard let resource = resourcesRepository.getResourceById(id: favoritedResource.id),
                      let appDeepLinkUrl = self.getToolUrlDeepLink(resource: resource, appLanguage: appLanguage) else {
                    return nil
                }

                return ToolShortcutLinkDomainModel(
                    appDeepLinkUrl: appDeepLinkUrl,
                    title: self.getToolName(resource: resource, appLanguage: appLanguage)
                )
            }
        
        return toolShortcutLinks
    }
    
    private func getToolUrlDeepLink(resource: ResourceDataModel, appLanguage: AppLanguageDomainModel) -> String? {

        guard let baseUrl = URL(string: Self.appDeepLinkBaseUrlString) else {
            return nil
        }

        return baseUrl
            .appending(path: appLanguage)
            .appending(path: resource.abbreviation)
            .appending(path: String(Self.toolDeepLinkPageNumber))
            .absoluteString
    }
    
    private func getToolName(resource: ResourceDataModel, appLanguage: AppLanguageDomainModel) -> String {
        
        let toolTranslation: TranslationDataModel?
        
        if let appLanguageTranslation = translationsRepository.getLatestTranslation(resourceId: resource.id, languageCode: appLanguage) {
            
            toolTranslation = appLanguageTranslation
        }
        else if let englishTranslation = translationsRepository.getLatestTranslation(resourceId: resource.id, languageCode: LanguageCodeDomainModel.english.value) {
            
            toolTranslation = englishTranslation
        }
        else {
            
            toolTranslation = nil
        }
        
        return toolTranslation?.translatedName ?? resource.name
    }
}
