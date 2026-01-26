//
//  GetLessonFilterLanguagesRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 7/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetLessonFilterLanguagesRepositoryInterface {
    
    @MainActor func getLessonFilterLanguagesPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[LessonFilterLanguageDomainModel], Error>
}
