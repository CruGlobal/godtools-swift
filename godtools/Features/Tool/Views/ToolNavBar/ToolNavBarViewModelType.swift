//
//  ToolNavBarViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolNavBarViewModelType {
    
    var navBarColor: UIColor { get }
    var navBarControlColor: UIColor { get }
    var hidesChooseLanguageControl: Bool { get }
    var navTitle: String { get }
    var numberOfLanguages: Int { get }
    var remoteShareIsActive: ObservableValue<Bool> { get }
    var selectedLanguage: ObservableValue<Int> { get }
    var language: LanguageModel { get }
    var hidesShareButton: Bool { get }
    
    func navHomeTapped()
    func shareTapped()
    func languageSegmentWillAppear(index: Int) -> ToolLanguageSegmentViewModel
    func languageTapped(index: Int)
}
