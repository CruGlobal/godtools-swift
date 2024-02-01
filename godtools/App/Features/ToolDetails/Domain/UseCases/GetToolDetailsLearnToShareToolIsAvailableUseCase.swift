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
    
    func getIsAvailablePublisher(tool: ToolDomainModel, language: BCP47LanguageIdentifier) -> AnyPublisher<Bool, Never> {
        
        return self.getToolDetailsLearnToShareToolIsAvailableRepository.getIsAvailablePublisher(tool: tool, language: language)
            .eraseToAnyPublisher()
    }
}
