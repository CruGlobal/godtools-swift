//
//  GetToolFilterLanguagesInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 3/21/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetToolFilterLanguagesInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolFilterLanguagesInterfaceStringsDomainModel, Never>
}
