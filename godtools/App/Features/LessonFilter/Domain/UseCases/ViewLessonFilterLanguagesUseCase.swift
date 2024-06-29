//
//  ViewLessonFilterLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 6/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewLessonFilterLanguagesUseCase {
    
    private let getInterfaceStringsRepository: GetLessonFilterLanguagesInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepository: GetLessonFilterLanguagesInterfaceStringsRepositoryInterface) {
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }
}
