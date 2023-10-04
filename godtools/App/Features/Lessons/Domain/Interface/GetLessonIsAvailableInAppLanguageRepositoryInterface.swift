//
//  GetLessonIsAvailableInAppLanguageRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/3/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetLessonIsAvailableInAppLanguageRepositoryInterface {
    
    func getLessonIsAvailableInAppLanguagePublisher(lesson: LessonDomainModel, appLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<Bool, Never>
}
