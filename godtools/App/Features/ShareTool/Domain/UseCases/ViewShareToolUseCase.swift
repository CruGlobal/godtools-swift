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
    
    func viewPublisher(toolId: String, toolLanguageId: String, pageNumber: Int, appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewShareToolDomainModel, Never> {
        
        return getInterfaceStringsRepository
            .getStringsPublisher(toolId: toolId, toolLanguageId: toolLanguageId, pageNumber: pageNumber, translateInLanguage: appLanguage)
            .map {
                return ViewShareToolDomainModel(
                    interfaceStrings: $0
                )
            }
            .eraseToAnyPublisher()
    }
}
