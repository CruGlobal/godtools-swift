//
//  GetResumeLessonProgressModalInterfaceStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetResumeLessonProgressModalInterfaceStringsUseCase {
    
    private let getResumeLessonModalInterfaceStringsRepo: GetResumeLessonProgressModalInterfaceStringsRepositoryInterface
    
    init(getResumeLessonModalInterfaceStringsRepo: GetResumeLessonProgressModalInterfaceStringsRepositoryInterface) {
        self.getResumeLessonModalInterfaceStringsRepo = getResumeLessonModalInterfaceStringsRepo
    }
    
    func getStringsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ResumeLessonProgressModalInterfaceStringsDomainModel, Never> {
        
        return getResumeLessonModalInterfaceStringsRepo
            .getStringsPublisher(translateInLanguage: appLanguage)
            .eraseToAnyPublisher()
    }
    
}
