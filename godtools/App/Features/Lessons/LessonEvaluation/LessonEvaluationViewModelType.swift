//
//  LessonEvaluationViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol LessonEvaluationViewModelType {
    
    var title: String { get }
    var wasThisHelpful: String { get }
    var yesButtonTitle: String { get }
    var noButtonTitle: String { get }
    var shareFaith: String { get }
    var sendButtonTitle: String { get }
    
    func closeTapped()
}
