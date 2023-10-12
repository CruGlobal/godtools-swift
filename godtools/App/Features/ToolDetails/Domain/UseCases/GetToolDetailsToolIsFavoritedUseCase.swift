//
//  GetToolDetailsToolIsFavoritedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolDetailsToolIsFavoritedUseCase {
    
    private let getToolDetailsToolIsFavoritedRepository: GetToolDetailsToolIsFavoritedRepositoryInterface
    
    init(getToolDetailsToolIsFavoritedRepository: GetToolDetailsToolIsFavoritedRepositoryInterface) {
        
        self.getToolDetailsToolIsFavoritedRepository = getToolDetailsToolIsFavoritedRepository
    }
    
    func getToolIsFavoritedPublisher(toolChangedPublisher: AnyPublisher<ToolDomainModel, Never>) -> AnyPublisher<Bool, Never> {
        
        Publishers.CombineLatest(
            toolChangedPublisher.eraseToAnyPublisher(),
            getToolDetailsToolIsFavoritedRepository.observeFavoritedToolsChangedPublisher()
        )
        .flatMap({ (tool: ToolDomainModel, favoritedToolsChanged: Void) -> AnyPublisher<Bool, Never> in
            
            return self.getToolDetailsToolIsFavoritedRepository.getToolIsFavorited(tool: tool)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
