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
    
    func viewPublisher(toolId: String, toolLanguageId: String, pageNumber: Int, appLanguage: AppLanguageDomainModel, resourceType: ResourceType) -> AnyPublisher<ViewShareToolDomainModel, Never> {
        
        return getInterfaceStringsRepository
            .getStringsPublisher(toolId: toolId, toolLanguageId: toolLanguageId, pageNumber: pageNumber, translateInLanguage: appLanguage, resourceType: resourceType)
            .map {
                return ViewShareToolDomainModel(
                    interfaceStrings: $0
                )
            }
            .eraseToAnyPublisher()
    }
}
