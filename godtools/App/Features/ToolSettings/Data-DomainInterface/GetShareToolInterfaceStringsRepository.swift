//
//  GetShareToolInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetShareToolInterfaceStringsRepository: GetShareToolInterfaceStringsRepositoryInterface {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let localizationServices: LocalizationServices
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, localizationServices: LocalizationServices) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(toolId: String, toolLanguageId: String, pageNumber: Int, translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ShareToolInterfaceStringsDomainModel, Never> {
        
        let localizedShareToolMessage: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "tract_share_message")
        
        guard let resource = resourcesRepository.getResource(id: toolId), let toolLanguage = languagesRepository.getLanguage(id: toolLanguageId) else {
            
            return Just(ShareToolInterfaceStringsDomainModel(shareMessage: localizedShareToolMessage))
                .eraseToAnyPublisher()
        }
        
        var toolUrl: String = "https://knowgod.com/\(toolLanguage.code)/\(resource.abbreviation)"

        if pageNumber > 0 {
            toolUrl = toolUrl.appending("/").appending("\(pageNumber)")
        }
        
        toolUrl = toolUrl.replacingOccurrences(of: " ", with: "").appending("?icid=gtshare ")
        
        let shareMessageWithToolUrl = String.localizedStringWithFormat(localizedShareToolMessage, toolUrl)

        let interfaceStrings = ShareToolInterfaceStringsDomainModel(
            shareMessage: shareMessageWithToolUrl
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
