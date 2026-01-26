//
//  GetLessonsListRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetLessonsListRepositoryInterface {
    
    @MainActor func getLessonsListPublisher(appLanguage: AppLanguageDomainModel, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> AnyPublisher<[LessonListItemDomainModel], Error>
}
