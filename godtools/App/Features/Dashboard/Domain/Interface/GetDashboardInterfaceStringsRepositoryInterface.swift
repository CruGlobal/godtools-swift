//
//  GetDashboardInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 1/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetDashboardInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<DashboardInterfaceStringsDomainModel, Never>
}
