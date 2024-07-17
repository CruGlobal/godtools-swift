//
//  GetGlobalActivityThisWeekRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 3/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetGlobalActivityThisWeekRepositoryInterface {
    
    func getActivityPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<[GlobalActivityThisWeekDomainModel], Never>
}
