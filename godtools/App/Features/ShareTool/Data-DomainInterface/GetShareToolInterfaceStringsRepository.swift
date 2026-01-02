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
        
        return Future { promise in
            
            do {
                
                let resource: ResourceDataModel? = try self.resourcesRepository.persistence.getDataModel(id: toolId)
                let toolLanguage: LanguageDataModel? = try self.languagesRepository.persistence.getDataModel(id: toolLanguageId)
                
                guard let resource = resource, let toolLanguage = toolLanguage else {
                    return promise(.success(defaultStrings))
                }
                
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
                
                return promise(.success(interfaceStrings))
                
            }
            catch let error {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
