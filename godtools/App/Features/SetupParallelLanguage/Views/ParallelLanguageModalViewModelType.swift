//
//  ParallelLanguageModalViewModelType.swift
//  godtools
//
//  Created by Robert Eldredge on 12/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ParallelLanguageModalViewModelType {
    
    var numberOfLanguages: ObservableValue<Int> { get }
    var selectedLanguageIndex: ObservableValue<Int?> { get }
    
    func languageWillAppear(index: Int) -> ChooseLanguageCellViewModel
    func languageTapped(index: Int)
}
