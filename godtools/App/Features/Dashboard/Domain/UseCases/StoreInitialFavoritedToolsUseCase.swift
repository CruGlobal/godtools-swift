//
//  StoreInitialFavoritedToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreInitialFavoritedToolsUseCase {
    
    private let storeInitialFavoritedTools: StoreInitialFavoritedToolsInterface
        
    init(storeInitialFavoritedTools: StoreInitialFavoritedToolsInterface) {
        
        self.storeInitialFavoritedTools = storeInitialFavoritedTools
    }
    
    func storeToolsPublisher() -> AnyPublisher<Void, Never> {
       
        return storeInitialFavoritedTools
            .storeInitialFavoritedToolsPublisher()
            .eraseToAnyPublisher()
    }
}
