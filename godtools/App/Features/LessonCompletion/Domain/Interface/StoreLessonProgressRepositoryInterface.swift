//
//  StoreLessonProgressRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 9/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol StoreLessonProgressRepositoryInterface {
    
    func storeLessonProgress(lessonId: String, lastViewedPageId: String, lastViewedPageNumber: Int, totalPageCount: Int) -> AnyPublisher<Void, Never>
}
