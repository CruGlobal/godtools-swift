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
    var navBarAttributes: ToolNavBarAttributes { get }
    var hidesChooseLanguageControl: Bool { get }
    var chooseLanguageControlPrimaryLanguageTitle: String { get }
    var chooseLanguageControlParallelLanguageTitle: String { get }
    var selectedLanguage: ObservableValue<Language> { get }
    var toolManifest: ManifestProperties { get }
    var toolXmlPages: ObservableValue<[XMLPage]> { get }
    var isRightToLeftLanguage: Bool { get }
    
    func pageViewed()
    func navHomeTapped()
    func shareTapped()
    func primaryLanguageTapped()
    func parallelLanguagedTapped()
    func viewLoaded()
}
