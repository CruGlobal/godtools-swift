//
//  GetAllFavoritedToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/3/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAllFavoritedToolsUseCase {
    
    private let getAllFavoritedResourceModelsUseCase: GetAllFavoritedResourceModelsUseCase
    
    init(getAllFavoritedResourceModelsUseCase: GetAllFavoritedResourceModelsUseCase) {
        
        self.getAllFavoritedResourceModelsUseCase = getAllFavoritedResourceModelsUseCase
    }
    
//    func getAllFavoritedToolsPublisherr() -> AnyPublisher<[FavoritedResourceModel], Never> {
//        
//        return favoritedResourcesRepository.getFavoritedResourcesChanged()
//            .flatMap({ void -> AnyPublisher<[FavoritedResourceModel], Never> in
//                
//                return Just(self.getAllFavoritedTools())
//                    .eraseToAnyPublisher()
//            })
//            .eraseToAnyPublisher()
//    }
//    
//    private func getAllFavoritedToolss() -> [ToolDomainModel] {
//        
//        let favoritedResourceModels = getAllFavoritedResourceModelsUseCase.getAllFavoritedTools()
//                
//        return favoritedResourcesRepository.getFavoritedResourcesSortedByCreatedAt(ascendingOrder: false)
//    }    
}
