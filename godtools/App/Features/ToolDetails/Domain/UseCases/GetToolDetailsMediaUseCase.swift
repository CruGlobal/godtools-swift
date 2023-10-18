//
//  GetToolDetailsMediaUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/4/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolDetailsMediaUseCase {
    
    private let getToolDetailsMediaRepository: GetToolDetailsMediaRepositoryInterface
    
    init(getToolDetailsMediaRepository: GetToolDetailsMediaRepositoryInterface) {
        
        self.getToolDetailsMediaRepository = getToolDetailsMediaRepository
    }
    
    func getMediaPublisher(toolChangedPublisher: AnyPublisher<ToolDomainModel, Never>) -> AnyPublisher<ToolDetailsMediaDomainModel, Never> {
        
        toolChangedPublisher
            .flatMap({ (tool: ToolDomainModel) -> AnyPublisher<ToolDetailsMediaDomainModel, Never> in
                
                return self.getToolDetailsMediaRepository.getMediaPublisher(tool: tool)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
