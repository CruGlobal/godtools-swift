//
//  GetSharablesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetSharablesUseCase {
    
    private let getSharablesRepository: GetSharablesRepositoryInterface
    
    init(getSharablesRepository: GetSharablesRepositoryInterface) {
        
        self.getSharablesRepository = getSharablesRepository
    }
    
    func getSharablesPublisher(resource: ResourceModel, appLanguage: AppLanguageDomainModel) -> AnyPublisher<[SharableDomainModel], Never> {
        
        return getSharablesRepository
            .getSharablesPublisher(resource: resource, translateInLanguage: appLanguage)
            .eraseToAnyPublisher()
    }
}
