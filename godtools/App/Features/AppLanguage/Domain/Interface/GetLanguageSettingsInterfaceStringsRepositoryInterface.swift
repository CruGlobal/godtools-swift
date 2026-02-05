//
//  GetLanguageSettingsInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetLanguageSettingsInterfaceStringsRepositoryInterface {
    
    @MainActor func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<LanguageSettingsInterfaceStringsDomainModel, Error>
}
