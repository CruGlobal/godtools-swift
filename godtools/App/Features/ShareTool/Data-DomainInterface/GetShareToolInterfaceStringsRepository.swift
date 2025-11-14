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
    
    enum ToolURLPath: String {
        case tract = "tool/v1"
        case cyoa = "tool/v2"
        case lesson = "lesson"
        
        init(resourceType: ResourceType) {
            switch resourceType {
            case .chooseYourOwnAdventure:
                self = .cyoa
            case .lesson:
                self = .lesson
            default:
                self = .tract
            }
        }
    }
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let localizationServices: LocalizationServicesInterface
        
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, localizationServices: LocalizationServicesInterface) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(toolId: String, toolLanguageId: String, pageNumber: Int, translateInLanguage: AppLanguageDomainModel, resourceType: ResourceType) -> AnyPublisher<ShareToolInterfaceStringsDomainModel, Never> {
        
        let localizedShareToolMessage: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "tract_share_message")
        
        guard let resource = resourcesRepository.persistence.getObject(id: toolId), let toolLanguage = languagesRepository.persistence.getObject(id: toolLanguageId) else {
            
            return Just(ShareToolInterfaceStringsDomainModel(shareMessage: localizedShareToolMessage))
                .eraseToAnyPublisher()
        }
        
        let path = ToolURLPath(resourceType: resourceType)
        var toolUrl: String = "https://knowgod.com/\(toolLanguage.code)/\(path.rawValue)/\(resource.abbreviation)"

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
