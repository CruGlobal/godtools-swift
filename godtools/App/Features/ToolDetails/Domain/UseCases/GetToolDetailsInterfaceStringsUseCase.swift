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
    
    func observeStringsPublisher(toolLanguageCodeChangedPublisher: AnyPublisher<String, Never>) -> AnyPublisher<ToolDetailsInterfaceStringsDomainModel, Never> {
        
        toolLanguageCodeChangedPublisher
            .flatMap({ (toolLanguageCode: String) -> AnyPublisher<ToolDetailsInterfaceStringsDomainModel, Never> in
              
                return self.getStringsPublisher(translateInToolLanguageCode: toolLanguageCode)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func getStringsPublisher(translateInToolLanguageCode: String) -> AnyPublisher<ToolDetailsInterfaceStringsDomainModel, Never> {
        
        return self.getToolDetailsInterfaceStringsRepository.getStringsPublisher(translateInToolLanguageCode: translateInToolLanguageCode)
            .eraseToAnyPublisher()
    }
}
