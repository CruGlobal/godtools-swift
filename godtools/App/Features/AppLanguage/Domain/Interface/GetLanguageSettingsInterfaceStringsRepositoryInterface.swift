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
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<LanguageSettingsInterfaceStringsDomainModel, Never>
}
