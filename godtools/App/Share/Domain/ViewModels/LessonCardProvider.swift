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
    
    @Published var lessons: [LessonDomainModel] = []
    
    // MARK: - Public
    
    func cardViewModel(for lesson: LessonDomainModel) -> BaseLessonCardViewModel {
        assertionFailure("This method should be overriden in the subclass")
        return BaseLessonCardViewModel()
    }
    
    func lessonTapped(lesson: LessonDomainModel) {}
}
