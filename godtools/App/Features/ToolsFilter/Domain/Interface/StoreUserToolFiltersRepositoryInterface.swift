//
//  StoreUserToolFiltersRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 11/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol StoreUserToolFiltersRepositoryInterface {
    
    func storeUserCategoryFilterPublisher(with id: String?) -> AnyPublisher<Void, Never>
    func storeUserLanguageFilterPublisher(with id: String?) -> AnyPublisher<Void, Never>
}
