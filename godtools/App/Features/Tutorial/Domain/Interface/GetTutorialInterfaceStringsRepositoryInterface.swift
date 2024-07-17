//
//  GetTutorialInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetTutorialInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<TutorialInterfaceStringsDomainModel, Never>
}
