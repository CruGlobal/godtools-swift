//
//  GetToolDetailsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolDetailsUseCase {
    
    private let getToolDetailsRepository: GetToolDetailsRepositoryInterface
    
    init(getToolDetailsRepository: GetToolDetailsRepositoryInterface) {
        
        self.getToolDetailsRepository = getToolDetailsRepository
    }
    
    func observeToolDetailsPublisher(toolChangedPublisher: AnyPublisher<ToolDomainModel, Never>, toolLanguageCodeChangedPublisher: AnyPublisher<String, Never>) -> AnyPublisher<ToolDetailsDomainModel, Never> {
        
        Publishers.CombineLatest(
            toolChangedPublisher.eraseToAnyPublisher(),
            toolLanguageCodeChangedPublisher.eraseToAnyPublisher()
        )
        .flatMap({ (tool: ToolDomainModel, toolLanguageCode: String) -> AnyPublisher<ToolDetailsDomainModel, Never> in
            
            return self.getToolDetailsPublisher(tool: tool, translateInToolLanguageCode: toolLanguageCode)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
    
    func getToolDetailsPublisher(tool: ToolDomainModel, translateInToolLanguageCode: String) -> AnyPublisher<ToolDetailsDomainModel, Never> {
        
        return self.getToolDetailsRepository.getDetailsPublisher(tool: tool, translateInToolLanguageCode: translateInToolLanguageCode)
            .eraseToAnyPublisher()
    }
}
