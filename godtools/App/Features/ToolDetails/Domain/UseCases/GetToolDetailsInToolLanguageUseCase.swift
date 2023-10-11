//
//  GetToolDetailsInToolLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolDetailsInToolLanguageUseCase {
    
    private let getToolDetailsRepositoryInterface: GetToolDetailsRepositoryInterface
    
    init(getToolDetailsRepositoryInterface: GetToolDetailsRepositoryInterface) {
        
        self.getToolDetailsRepositoryInterface = getToolDetailsRepositoryInterface
    }
    
    func getToolsDetailsPublisher(toolPublisher: AnyPublisher<ToolDomainModel, Never>, toolLanguageCodePublisher: AnyPublisher<String, Never>) -> AnyPublisher<ToolDetailsDomainModel, Never> {
        
        Publishers.CombineLatest(
            toolPublisher.eraseToAnyPublisher(),
            toolLanguageCodePublisher.eraseToAnyPublisher()
        )
        .flatMap({ (tool: ToolDomainModel, toolLanguageCode: String) -> AnyPublisher<ToolDetailsDomainModel, Never> in
            
            return self.getToolDetailsRepositoryInterface.getToolDetailsPublisher(tool: tool, inToolLanguageCode: toolLanguageCode)
        })
        .eraseToAnyPublisher()
    }
}
