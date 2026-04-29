//
//  Persistence+Publisher.swift
//  godtools
//
//  Created by Levi Eggert on 4/29/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import Combine

extension Persistence {
    
    // TODO: Eventually should be removed in favor of using async await. ~Levi
    func getDataModelsPublisher(getOption: PersistenceGetOption) -> AnyPublisher<[DataModelType], Error> {
        return AnyPublisher() {
            return try await getDataModelsAsync(getOption: getOption)
        }
    }
}
