//
//  GetLessonEvaluatedRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetLessonEvaluatedRepositoryInterface {
    
    func getLessonEvaluatedPublisher(lessonId: String) -> AnyPublisher<Bool, Never>
}
