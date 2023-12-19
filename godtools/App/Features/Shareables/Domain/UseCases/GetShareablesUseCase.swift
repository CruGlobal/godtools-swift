//
//  GetShareablesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetShareablesUseCase {
    
    private let getShareablesRepository: GetShareablesRepositoryInterface
    
    init(getShareablesRepository: GetShareablesRepositoryInterface) {
        
        self.getShareablesRepository = getShareablesRepository
    }
    
    func getShareablesPublisher(resource: ResourceModel, appLanguage: AppLanguageDomainModel) -> AnyPublisher<[ShareableDomainModel], Never> {
        
        return getShareablesRepository
            .getShareablesPublisher(resource: resource, translateInLanguage: appLanguage)
            .eraseToAnyPublisher()
    }
}
