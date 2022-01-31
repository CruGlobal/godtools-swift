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
    var yesButtonText: String { get }
    var noButtonText: String { get }
    var selectButtonText: String { get }
    var getStartedButtonText: String { get }
    var selectLanguageButtonText: ObservableValue<String> { get }
    var yesNoButtonsHidden:  ObservableValue<Bool> { get }
    var getStartedButtonHidden:  ObservableValue<Bool> { get }
    
    func languageSelectorTapped()
    func yesButtonTapped()
    func noButtonTapped()
    func getStartedButtonTapped()
}
