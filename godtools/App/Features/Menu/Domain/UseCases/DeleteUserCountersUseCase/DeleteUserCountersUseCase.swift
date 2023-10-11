//
//  DeleteUserCountersUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 10/9/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class DeleteUserCountersUseCase {
    
    private let repository: UserCountersRepository
        
    init(repository: UserCountersRepository) {
        
        self.repository = repository
    }
    
    func deleteUserCountersPublisher() -> AnyPublisher<Void, Error> {
        
        return repository.deleteUserCounters()
    }
}
