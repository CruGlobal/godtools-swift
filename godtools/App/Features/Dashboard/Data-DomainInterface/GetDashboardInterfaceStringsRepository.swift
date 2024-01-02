//
//  GetDashboardInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 1/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetDashboardInterfaceStringsRepository: GetDashboardInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<DashboardInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInLanguage
        
        let interfaceStrings = DashboardInterfaceStringsDomainModel(
            lessonsActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tool_menu_item.lessons"),
            favoritesActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "my_tools"),
            toolsActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tool_menu_item.tools")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
