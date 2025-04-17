//
//  GetOptInDialogInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Jason Bennett on 3/27/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetOptInDialogInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<OptInDialogInterfaceStringsDomainModel, Never>
}
