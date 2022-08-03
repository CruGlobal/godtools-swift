//
//  LessonCardProvider.swift
//  godtools
//
//  Created by Rachael Skeath on 6/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class LessonCardProvider: NSObject, ObservableObject {
    
    // MARK: - Published
    
    @Published var lessons: [ResourceModel] = []
    
    // MARK: - Public
    
    func cardViewModel(for lesson: ResourceModel) -> BaseLessonCardViewModel {
        assertionFailure("This method should be overriden in the subclass")
        return MockLessonCardViewModel()
    }
    
    func lessonTapped(resource: ResourceModel) {}
}
