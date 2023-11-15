//
//  GetLessonEvaluationInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetLessonEvaluationInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonEvaluationInterfaceStringsDomainModel, Never>
}
