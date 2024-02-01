//
//  GetConfirmAppLanguageInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 1/27/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetConfirmAppLanguageInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel, selectedLanguage: AppLanguageDomainModel) -> AnyPublisher<ConfirmAppLanguageInterfaceStringsDomainModel, Never>
}
