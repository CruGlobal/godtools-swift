//
//  GetUserFiltersRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 11/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetUserFiltersRepositoryInterface {
    
    func getUserCategoryFilterPublisher() -> AnyPublisher<String?, Never>
    func getUserLanguageFilterPublisher() -> AnyPublisher<String?, Never>
}
