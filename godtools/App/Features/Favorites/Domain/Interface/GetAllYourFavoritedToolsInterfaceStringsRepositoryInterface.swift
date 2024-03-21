//
//  GetAllYourFavoritedToolsInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetAllYourFavoritedToolsInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<AllYourFavoritedToolsInterfaceStringsDomainModel, Never>
}
