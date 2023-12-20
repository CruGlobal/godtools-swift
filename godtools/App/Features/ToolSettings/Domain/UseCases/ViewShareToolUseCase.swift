//
//  ViewShareToolUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewShareToolUseCase {
    
    private let getInterfaceStringsRepository: GetShareToolInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepository: GetShareToolInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }
    
    func viewPublisher(resource: ResourceModel, language: LanguageDomainModel, pageNumber: Int, appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewShareToolDomainModel, Never> {
        
        return getInterfaceStringsRepository
            .getStringsPublisher(resource: resource, language: language, pageNumber: pageNumber, translateInLanguage: appLanguage)
            .map {
                return ViewShareToolDomainModel(
                    interfaceStrings: $0
                )
            }
            .eraseToAnyPublisher()
    }
}
