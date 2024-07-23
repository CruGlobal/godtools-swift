//
//  StoreUserLessonFiltersRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 7/8/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol StoreUserLessonFiltersRepositoryInterface {
    
    func storeUserLanguageFilterPublisher(_ languageFilter: LessonLanguageFilterDomainModel) -> AnyPublisher<Void, Never>
}
