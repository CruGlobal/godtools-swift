//
//  ViewReviewShareShareableUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewReviewShareShareableUseCase {
    
    private let getInterfaceStringsRepository: GetReviewShareShareableInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepository: GetReviewShareShareableInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewReviewShareShareableDomainModel, Never> {
        
        return getInterfaceStringsRepository
            .getStringsPublisher(translateInLanguage: appLanguage)
            .map {
                return ViewReviewShareShareableDomainModel(
                    interfaceStrings: $0
                )
            }
            .eraseToAnyPublisher()
    }
}
