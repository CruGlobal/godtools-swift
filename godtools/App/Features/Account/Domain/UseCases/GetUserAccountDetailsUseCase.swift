//
//  GetUserAccountDetailsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import LocalizationServices

class GetUserAccountDetailsUseCase {
    
    private let getUserAccountDetailsRepository: GetUserAccountDetailsRepositoryInterface
    
    init(getUserAccountDetailsRepository: GetUserAccountDetailsRepositoryInterface) {
        
        self.getUserAccountDetailsRepository = getUserAccountDetailsRepository
    }
    
    func getUserAccountDetailsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<UserAccountDetailsDomainModel, Never> {
        
        return getUserAccountDetailsRepository.getUserAccountDetailsPublisher(appLanguage: appLanguage)
    }
}
