//
//  GetFeaturedLessonsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetFeaturedLessonsRepositoryInterface {
    
    func getFeaturedLessonsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[FeaturedLessonDomainModel], Never>
}
