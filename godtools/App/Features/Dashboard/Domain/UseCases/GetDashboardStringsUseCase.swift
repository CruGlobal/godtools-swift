//
//  GetDashboardStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetDashboardStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<DashboardStringsDomainModel, Never> {
        
        let localeId: String = translateInLanguage
        
        let interfaceStrings = DashboardStringsDomainModel(
            lessonsActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tool_menu_item.lessons"),
            favoritesActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "my_tools"),
            toolsActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tool_menu_item.tools")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
