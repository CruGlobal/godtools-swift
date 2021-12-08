//
//  SetupParallelLanguageViewModelType.swift
//  godtools
//
//  Created by Robert Eldredge on 11/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol SetupParallelLanguageViewModelType {
    
    var animatedViewModel: AnimatedViewModel { get }
    var promptText: String { get }
    var languagePickerLabelText: String { get }
    var yesButtonText: String { get }
    var noButtonText: String { get }
    var selectButtonText: String { get }
    var getStartedButtonText: String { get }
    
    func selectLanguageTapped()
    func closeButtonTapped()
    func yesButtonTapped()
    func noButtonTapped()
    func languageSelected(index: Int)
    func getStartedButtonTapped()
}
