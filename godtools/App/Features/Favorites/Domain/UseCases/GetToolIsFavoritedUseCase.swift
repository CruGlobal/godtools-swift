//
//  GetToolIsFavoritedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/4/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolIsFavoritedUseCase {
    
    private let getToolIsFavoritedRepository: GetToolIsFavoritedRepositoryInterface
    
    init(getToolIsFavoritedRepository: GetToolIsFavoritedRepositoryInterface) {
        
        self.getToolIsFavoritedRepository = getToolIsFavoritedRepository
    }
    
    func getToolIsFavoritedPublisher(toolId: String) -> AnyPublisher<ToolIsFavoritedDomainModel, Never>  {
        
        return getToolIsFavoritedRepository
            .getIsFavoritedPublisher(toolId: toolId)
            .eraseToAnyPublisher()
    }
}
