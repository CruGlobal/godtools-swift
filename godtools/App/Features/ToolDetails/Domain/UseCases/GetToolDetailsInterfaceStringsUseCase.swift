//
//  GetToolDetailsInterfaceStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/10/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolDetailsInterfaceStringsUseCase {
    
    private let getToolDetailsInterfaceStringsRepository: GetToolDetailsInterfaceStringsRepositoryInterface
    
    init(getToolDetailsInterfaceStringsRepository: GetToolDetailsInterfaceStringsRepositoryInterface) {
        
        self.getToolDetailsInterfaceStringsRepository = getToolDetailsInterfaceStringsRepository
    }
    
    func getStringsPublisher(toolLanguageCodeChangedPublisher: AnyPublisher<String, Never>) -> AnyPublisher<ToolDetailsInterfaceStringsDomainModel, Never> {
        
        toolLanguageCodeChangedPublisher
            .flatMap({ (toolLanguageCode: String) -> AnyPublisher<ToolDetailsInterfaceStringsDomainModel, Never> in
              
                return self.getToolDetailsInterfaceStringsRepository.getStringsPublisher(translateInToolLanguage: toolLanguageCode)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
