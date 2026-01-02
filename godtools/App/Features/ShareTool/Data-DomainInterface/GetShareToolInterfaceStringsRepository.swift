//
//  GetShareToolInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import RepositorySync

class GetShareToolInterfaceStringsRepository: GetShareToolInterfaceStringsRepositoryInterface {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let localizationServices: LocalizationServicesInterface
        
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, localizationServices: LocalizationServicesInterface) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.localizationServices = localizationServices
    }
    
    @MainActor func getStringsPublisher(toolId: String, toolLanguageId: String, pageNumber: Int, translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ShareToolInterfaceStringsDomainModel, Error> {
        
        let localizedShareToolMessage: String = localizationServices.stringForLocaleElseEnglish(
            localeIdentifier: translateInLanguage, key: "tract_share_message"
        )
        
        let defaultStrings = ShareToolInterfaceStringsDomainModel(
            shareMessage: localizedShareToolMessage
        )
        
        return getToolLanguagePublisher(
            toolId: toolId,
            toolLanguageId: toolLanguageId
        )
        .map { (tuple: (resource: ResourceDataModel, language: LanguageDataModel)?) in
            
            guard let tuple = tuple else {
                return defaultStrings
            }
            
            let resource: ResourceDataModel = tuple.resource
            let toolLanguage: LanguageDataModel = tuple.language
            
            let resourceType: ResourceType = resource.resourceTypeEnum
            
            let path = ShareToolURLPath(resourceType: resourceType)
            var toolUrl: String = "https://knowgod.com/\(toolLanguage.code)/\(path.rawValue)/\(resource.abbreviation)"

            if pageNumber > 0 {
                toolUrl = toolUrl.appending("/").appending("\(pageNumber)")
            }
            
            toolUrl = toolUrl.replacingOccurrences(of: " ", with: "").appending("?icid=gtshare ")
            
            let shareMessageWithToolUrl = String.localizedStringWithFormat(localizedShareToolMessage, toolUrl)

            let interfaceStrings = ShareToolInterfaceStringsDomainModel(
                shareMessage: shareMessageWithToolUrl
            )
            
            return interfaceStrings
        }
        .eraseToAnyPublisher()
    }
    
    @MainActor private func getToolLanguagePublisher(toolId: String, toolLanguageId: String) -> AnyPublisher<(ResourceDataModel, LanguageDataModel)?, Error> {
        
        return resourcesRepository
            .persistence
            .getDataModelsPublisher(getOption: .object(id: toolId))
            .asyncMap { (resources: [ResourceDataModel]) in
                
                guard let resource = resources.first else {
                    return nil
                }
                
                let language: LanguageDataModel? = try await self.languagesRepository.persistence.getDataModelsAsync(
                    getOption: .object(id: toolLanguageId)
                ).first
                
                guard let language = language else {
                    return nil
                }
                
                return (resource, language)
            }
            .eraseToAnyPublisher()
    }
}
