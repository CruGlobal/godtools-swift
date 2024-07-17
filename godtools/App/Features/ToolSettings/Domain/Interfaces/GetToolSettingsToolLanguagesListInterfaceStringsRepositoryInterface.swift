//
//  GetToolSettingsToolLanguagesListInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 12/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetToolSettingsToolLanguagesListInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolSettingsToolLanguagesListInterfaceStringsDomainModel, Never>
}
