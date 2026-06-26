//
//  GetCreatingToolScreenShareSessionStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetCreatingToolScreenShareSessionStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> CreatingToolScreenShareSessionStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let strings = CreatingToolScreenShareSessionStringsDomainModel(
            creatingSessionMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.loadToolRemoteSessionMessage.key)
        )
        
        return strings
    }
}
