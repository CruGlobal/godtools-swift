//
//  SelectedToolFilterLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class SelectedToolFilterLanguageUseCase {
    
    private let userToolFiltersRepository: UserToolFiltersRepository
    
    init(userToolFiltersRepository: UserToolFiltersRepository) {
        
        self.userToolFiltersRepository = userToolFiltersRepository
    }
    
    func execute(id: String?) -> AnyPublisher<Void, Never> {
        
        if let id = id, !id.isEmpty {
            
            Task {
                try await userToolFiltersRepository
                    .storeUserLanguageFilter(languageId: id)
            }
        }
        else {
            
            do {
                try userToolFiltersRepository.deleteUserLanguageFilter()
            }
            catch _ {
                
            }
        }
                
        return Just(())
            .eraseToAnyPublisher()
    }
}
