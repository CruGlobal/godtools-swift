//
//  ViewGlobalActivityThisWeekUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewGlobalActivityThisWeekUseCase {
    
    private let getGlobalActivityRepository: GetGlobalActivityThisWeekRepositoryInterface
    
    init(getGlobalActivityRepository: GetGlobalActivityThisWeekRepositoryInterface) {
        
        self.getGlobalActivityRepository = getGlobalActivityRepository
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewGlobalActivityThisWeekDomainModel, Never> {
        
        return getGlobalActivityRepository
            .getActivityPublisher(translateInLanguage: appLanguage)
            .map {
                
                ViewGlobalActivityThisWeekDomainModel(
                    activityItems: $0
                )
            }
            .eraseToAnyPublisher()
    }
}
