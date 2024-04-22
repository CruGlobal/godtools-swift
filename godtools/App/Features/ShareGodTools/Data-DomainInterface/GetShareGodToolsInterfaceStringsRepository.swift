//
//  GetShareGodToolsInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 4/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetShareGodToolsInterfaceStringsRepository: GetShareGodToolsInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func getInterfaceStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ShareGodToolsInterfaceStringsDomainModel, Never> {
                
        let interfaceStrings = ShareGodToolsInterfaceStringsDomainModel(
            shareMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "share_god_tools_share_sheet_text", fileType: .strings)
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
