//
//  TractViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol TractViewModelType {
    
    var resource: DownloadedResource { get }
    var navTitle: ObservableValue<String> { get }
    var navBarAttributes: TractNavBarAttributes { get }
    var hidesChooseLanguageControl: Bool { get }
    var chooseLanguageControlPrimaryLanguageTitle: String { get }
    var chooseLanguageControlParallelLanguageTitle: String { get }
    var selectedTractLanguage: ObservableValue<TractLanguage> { get }
    var primaryLanguage: Language { get }
    var parallelLanguage: Language? { get }
    var tractManifest: ManifestProperties { get }
    var primaryTractPages: [XMLPage] { get }
    var tractXmlPageItems: ObservableValue<[TractXmlPageItem]> { get }
    var currentTractPageItemIndex: ObservableValue<AnimatableValue<Int>> { get }
    var isRightToLeftLanguage: Bool { get }
    var currentTractPage: Int { get }
    
    func navHomeTapped()
    func shareTapped()
    func primaryLanguageTapped()
    func parallelLanguagedTapped()
    func viewLoaded()
    func didScrollToTractPage(page: Int)
    func navigateToNextPageTapped()
    func navigateToPreviousPageTapped()
    func navigateToPageTapped(page: Int)
    func sendEmailTapped(subject: String?, message: String?, isHtml: Bool?)
}
