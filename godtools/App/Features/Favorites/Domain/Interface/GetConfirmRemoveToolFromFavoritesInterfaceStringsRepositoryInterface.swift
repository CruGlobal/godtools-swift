//
//  GetConfirmRemoveToolFromFavoritesInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 2/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetConfirmRemoveToolFromFavoritesInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(toolId: String, translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ConfirmRemoveToolFromFavoritesInterfaceStringsDomainModel, Never>
}
