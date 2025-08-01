//
//  GetUserAccountDetailsRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetUserAccountDetailsRepositoryInterface {
    
    func getUserAccountDetailsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<UserAccountDetailsDomainModel, Never>
}

