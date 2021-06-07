//
//  LessonsListViewType.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol LessonsListViewModelType {
    
    var numberOfLessons: ObservableValue<Int> { get }
    var isLoading: ObservableValue<Bool> { get }
    var didEndRefreshing: Signal { get }
    
    func pageViewed()
    func lessonWillAppear(index: Int) -> LessonListItemViewModelType
    func lessonTapped(index: Int)
    func refreshLessons()
}
