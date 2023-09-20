//
//  GetAppLanguagesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAppLanguagesUseCase {
            
    private let getAppLanguagesRepository: GetAppLanguagesRepositoryInterface
    
    init(getAppLanguagesRepository: GetAppLanguagesRepositoryInterface) {
        
        self.getAppLanguagesRepository = getAppLanguagesRepository
    }
    
    func getAppLanguagesPublisher() -> AnyPublisher<[AppLanguageDomainModel], Never> {
        
        return getAppLanguagesRepository.getAppLanguagesPublisher()
            .eraseToAnyPublisher()
    }
}
