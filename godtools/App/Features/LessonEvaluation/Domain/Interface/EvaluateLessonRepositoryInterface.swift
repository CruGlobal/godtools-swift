//
//  EvaluateLessonRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol EvaluateLessonRepositoryInterface {
    
    func evaluateLessonPublisher(lessonId: String, feedback: TrackLessonFeedbackDomainModel) -> AnyPublisher<Void, Never>
}
