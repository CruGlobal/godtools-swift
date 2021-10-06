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
    var readyToShareFaithMinimumScaleValue: Int { get }
    var readyToShareFaithMaximumScaleValue: Int { get }
    var readyToShareFaithScale: Int { get }
    var sendButtonTitle: String { get }
    var yesIsSelected: ObservableValue<Bool> { get }
    var noIsSelected: ObservableValue<Bool> { get }
    
    func closeTapped()
    func yesTapped()
    func noTapped()
    func didSetScaleForReadyToShareFaith(scale: Int)
    func sendTapped()
}
