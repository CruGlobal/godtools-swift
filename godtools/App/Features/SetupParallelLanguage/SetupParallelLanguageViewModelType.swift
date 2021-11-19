//
//  SetupParallelLanguageViewModelType.swift
//  godtools
//
//  Created by Robert Eldredge on 11/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol SetupParallelLanguageViewModelType {
    
    var animationViewModel: AnimatedViewModel { get }
    var bodyText: String { get }
    var languagePickerLabelText: String { get }
    var yesButtonText: String { get }
    var noButtonText: String { get }
    var selectButtonText: String { get }
    var getStartedButtonText: String { get }
    
    func handleYesTapped()
    func handleNoTapped()
    func handleLanguageSelected(index: Int)
    func handleGetStartedTapped()
}
