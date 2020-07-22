//
//  TractViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol TractViewModelType {
    
    var navTitle: ObservableValue<String> { get }
    var navBarAttributes: TractNavBarAttributes { get }
    var hidesChooseLanguageControl: Bool { get }
    var chooseLanguageControlPrimaryLanguageTitle: String { get }
    var chooseLanguageControlParallelLanguageTitle: String { get }
    var selectedTractLanguage: ObservableValue<TractLanguage> { get }
    var primaryTractManifest: ManifestProperties { get }
    var primaryTractPages: [XMLPage] { get }
    var tractXmlPageItems: ObservableValue<[TractXmlPageItem]> { get }
    var currentTractPage: ObservableValue<AnimatableValue<Int>> { get }
    var isRightToLeftLanguage: Bool { get }
    
    func navHomeTapped()
    func shareTapped()
    func primaryLanguageTapped()
    func parallelLanguagedTapped()
    func viewLoaded()
    func tractPageDidChange(page: Int)
    func tractPageDidAppear(page: Int)
    func sendEmailTapped(subject: String?, message: String?, isHtml: Bool?)
    func getTractPage(page: Int) -> TractPage?
}
