//
//  LessonViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol LessonViewModelType: MobileContentPagesViewModel {
    
    var progress: ObservableValue<AnimatableValue<CGFloat>> { get }
    
    func lessonMostVisiblePageDidChange(page: Int)
    func closeTapped()
}
