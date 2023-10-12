//
//  GetToolDetailsLearnToShareToolIsAvailableUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolDetailsLearnToShareToolIsAvailableUseCase {
    
    private let getToolDetailsLearnToShareToolIsAvailableRepository: GetToolDetailsLearnToShareToolIsAvailableRepositoryInterface
    
    init(getToolDetailsLearnToShareToolIsAvailableRepository: GetToolDetailsLearnToShareToolIsAvailableRepositoryInterface) {
        
        self.getToolDetailsLearnToShareToolIsAvailableRepository = getToolDetailsLearnToShareToolIsAvailableRepository
    }
    
    func getIsAvailablePublisher(toolChangedPublisher: AnyPublisher<ToolDomainModel, Never>, toolLanguageCodeChangedPublisher: AnyPublisher<String, Never>) -> AnyPublisher<Bool, Never> {
        
        Publishers.CombineLatest(
            toolChangedPublisher.eraseToAnyPublisher(),
            toolLanguageCodeChangedPublisher.eraseToAnyPublisher()
        )
        .flatMap({ (tool: ToolDomainModel, toolLanguageCode: String) -> AnyPublisher<Bool, Never> in
            
            return self.getToolDetailsLearnToShareToolIsAvailableRepository.getIsAvailablePublisher(tool: tool, toolLanguageCode: toolLanguageCode)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
