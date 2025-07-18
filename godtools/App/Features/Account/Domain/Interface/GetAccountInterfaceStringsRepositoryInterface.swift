//
//  GetAccountInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 2/17/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetAccountInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<AccountInterfaceStringsDomainModel, Never>
}
