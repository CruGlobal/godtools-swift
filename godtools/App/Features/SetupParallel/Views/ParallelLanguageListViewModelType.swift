//
//  ParallelLanguageListViewModelType.swift
//  godtools
//
//  Created by Robert Eldredge on 12/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ParallelLanguageListViewModelType {
    
    var selectButtonText: String { get }
    var numberOfLanguages: ObservableValue<Int> { get }
    
    func languageWillAppear(index: Int) -> ChooseLanguageCellViewModel
    func languageTapped(index: Int)
}
