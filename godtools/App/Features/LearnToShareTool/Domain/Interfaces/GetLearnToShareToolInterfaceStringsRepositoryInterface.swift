//
//  GetLearnToShareToolInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 12/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetLearnToShareToolInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<LearnToShareToolInterfaceStringsDomainModel, Never>
}
