//
//  GetNotificationsInterfaceStringsRepository.swift
//  godtools
//
//  Created by Jason Bennett on 3/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//


import Foundation
import Combine

protocol GetOptInNotificationsInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<OptInNotificationsStringsDomainModel, Never>
}
