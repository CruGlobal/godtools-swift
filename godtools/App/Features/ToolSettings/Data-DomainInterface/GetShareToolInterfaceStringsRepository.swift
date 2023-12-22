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
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    // TODO: Eventually shouldn't depend on ResourceModel here.  Should be a domain model. ~Levi
    func getStringsPublisher(tool: ResourceModel, toolLanguage: LanguageDomainModel, pageNumber: Int, translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ShareToolInterfaceStringsDomainModel, Never> {
        
        var toolUrl: String = "https://knowgod.com/\(toolLanguage.localeIdentifier)/\(tool.abbreviation)"

        if pageNumber > 0 {
            toolUrl = toolUrl.appending("/").appending("\(pageNumber)")
        }
        
        toolUrl = toolUrl.replacingOccurrences(of: " ", with: "").appending("?icid=gtshare ")

        let localizedShareToolMessage: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "tract_share_message")
        
        let shareMessageWithToolUrl: String = String.localizedStringWithFormat(localizedShareToolMessage, toolUrl)
        
        let interfaceStrings = ShareToolInterfaceStringsDomainModel(
            shareMessage: shareMessageWithToolUrl
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
