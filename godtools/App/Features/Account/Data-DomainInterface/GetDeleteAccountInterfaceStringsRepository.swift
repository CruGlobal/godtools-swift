//
//  GetDeleteAccountInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine
import LocalizationServices

class GetDeleteAccountInterfaceStringsRepository: GetDeleteAccountInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<DeleteAccountInterfaceStringsDomainModel, Never> {
        
        let interfaceStrings = DeleteAccountInterfaceStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInAppLanguage, key: MenuStringKeys.DeleteAccount.title.rawValue),
            subtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInAppLanguage, key: MenuStringKeys.DeleteAccount.subtitle.rawValue),
            confirmActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInAppLanguage, key: MenuStringKeys.DeleteAccount.confirmButtonTitle.rawValue),
            cancelActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInAppLanguage, key: MenuStringKeys.DeleteAccount.cancelButtonTitle.rawValue)
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
