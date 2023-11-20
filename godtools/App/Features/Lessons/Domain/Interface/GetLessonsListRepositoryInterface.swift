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
    
    func getLessonsListPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[LessonListItemDomainModel], Never>
    func observeLessonsChangedPublisher() -> AnyPublisher<Void, Never>
}
