//
//  StoreInitialAppLanguageInterface.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol StoreInitialAppLanguageInterface {
    
    func storeInitialAppLanguagePublisher() -> AnyPublisher<AppLanguageDomainModel, Never>
}
