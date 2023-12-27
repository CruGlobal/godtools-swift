//
//  GetReviewShareShareableInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 12/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetReviewShareShareableInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ReviewShareShareableInterfaceStringsDomainModel, Never>
}
