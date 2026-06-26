//
//  GetShareGodToolsStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 4/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetShareGodToolsStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> ShareGodToolsStringsDomainModel {
                
        let strings = ShareGodToolsStringsDomainModel(
            shareMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "share_god_tools_share_sheet_text")
        )
        
        return strings
    }
}
