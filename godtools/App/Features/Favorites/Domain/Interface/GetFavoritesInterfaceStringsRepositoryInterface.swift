//
//  GetFavoritesInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetFavoritesInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<FavoritesInterfaceStringsDomainModel, Never>
}
