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
    
    func getToolDetailsPublisher(toolPublisher: AnyPublisher<ToolDomainModel, Never>, toolLanguageCodePublisher: AnyPublisher<String, Never>) -> AnyPublisher<ToolDetailsDomainModel, Never> {
        
        Publishers.CombineLatest(
            toolPublisher.eraseToAnyPublisher(),
            toolLanguageCodePublisher.eraseToAnyPublisher()
        )
        .flatMap({ (tool: ToolDomainModel, toolLanguageCode: String) -> AnyPublisher<ToolDetailsDomainModel, Never> in
            
            return self.getToolDetailsRepository.getDetailsPublisher(tool: tool, translateInToolLanguageCode: toolLanguageCode)
        })
        .eraseToAnyPublisher()
    }
}
