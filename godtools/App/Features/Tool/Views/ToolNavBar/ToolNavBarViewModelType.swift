//
//  ToolNavBarViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolNavBarViewModelType {
    
    var backButtonImage: UIImage { get }
    var navBarColor: UIColor { get }
    var navBarControlColor: UIColor { get }
    var navBarFont: UIFont { get }
    var hidesChooseLanguageControl: Bool { get }
    var navTitle: String? { get }
    var numberOfLanguages: Int { get }
    var remoteShareIsActive: ObservableValue<Bool> { get }
    var selectedLanguage: ObservableValue<Int> { get }
    var languageControlFont: UIFont { get }
    var language: LanguageModel { get }
    var languages: [LanguageModel] { get }
    
    func languageSegmentWillAppear(index: Int) -> ToolLanguageSegmentViewModel
    func languageTapped(index: Int)
}
