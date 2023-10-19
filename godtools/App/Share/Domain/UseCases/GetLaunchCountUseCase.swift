//
//  GetLaunchCountUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLaunchCountUseCase {
    
    private let getLaunchCountRepositoryInterface: GetLaunchCountRepositoryInterface
    
    init(getLaunchCountRepositoryInterface: GetLaunchCountRepositoryInterface) {
        
        self.getLaunchCountRepositoryInterface = getLaunchCountRepositoryInterface
    }
    
    func getCountPublisher() -> AnyPublisher<Int, Never> {
        
        return getLaunchCountRepositoryInterface.getCountPublisher()
            .eraseToAnyPublisher()
    }
}
