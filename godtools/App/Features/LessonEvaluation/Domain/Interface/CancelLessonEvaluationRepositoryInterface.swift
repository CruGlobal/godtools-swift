//
//  CancelLessonEvaluationRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol CancelLessonEvaluationRepositoryInterface {
    
    func cancelPublisher(lessonId: String) -> AnyPublisher<Void, Never>
}
