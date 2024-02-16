//
//  ViewToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewToolsUseCase {
    
    init() {
        
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewToolsDomainModel, Never> {
        
        return Just(ViewToolsDomainModel())
            .eraseToAnyPublisher()
    }
}
