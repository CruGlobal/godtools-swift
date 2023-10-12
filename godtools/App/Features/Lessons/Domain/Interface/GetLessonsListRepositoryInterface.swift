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
    
    func getLessonsListPublisher(currentAppLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<[LessonListItemDomainModel], Never>
    func observeLessonsChangedPublisher() -> AnyPublisher<Void, Never>
}
