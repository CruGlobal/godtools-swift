//
//  GetDeleteAccountStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetDeleteAccountStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<DeleteAccountStringsDomainModel, Never> {
        
        let strings = DeleteAccountStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: MenuStringKeys.DeleteAccount.title.rawValue),
            subtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: MenuStringKeys.DeleteAccount.subtitle.rawValue),
            confirmActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: MenuStringKeys.DeleteAccount.confirmButtonTitle.rawValue),
            cancelActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: MenuStringKeys.DeleteAccount.cancelButtonTitle.rawValue)
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
