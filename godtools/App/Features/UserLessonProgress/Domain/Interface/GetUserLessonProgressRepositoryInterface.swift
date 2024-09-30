//
//  GetUserLessonProgressRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 9/24/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetUserLessonProgressRepositoryInterface {
    
    func getLessonProgressPublisher(lessonId: String) -> AnyPublisher<UserLessonProgressDomainModel?, Never>
}
