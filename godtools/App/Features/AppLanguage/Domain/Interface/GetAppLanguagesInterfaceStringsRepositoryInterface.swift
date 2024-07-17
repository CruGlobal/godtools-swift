//
//  GetAppLanguagesInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetAppLanguagesInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<AppLanguagesInterfaceStringsDomainModel, Never>
}
