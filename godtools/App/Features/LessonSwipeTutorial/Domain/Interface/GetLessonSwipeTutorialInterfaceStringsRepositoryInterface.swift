//
//  GetLessonSwipeTutorialInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetLessonSwipeTutorialInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonSwipeTutorialInterfaceStringsDomainModel, Never>
}
