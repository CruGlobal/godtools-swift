//
//  LanguageSettingsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LanguageSettingsViewModel: LanguageSettingsViewModelType {

    private let languagesManager: LanguagesManager
    private let analytics: GodToolsAnaltyics
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: NSLocalizedString("language_settings", comment: ""))
    let primaryLanguageButtonTitle: ObservableValue<String> = ObservableValue(value: "")
    let parallelLanguageButtonTitle: ObservableValue<String> = ObservableValue(value: "")
    
    required init(flowDelegate: FlowDelegate, languagesManager: LanguagesManager, analytics: GodToolsAnaltyics) {
        
        self.flowDelegate = flowDelegate
        self.languagesManager = languagesManager
        self.analytics = analytics
        
        reloadPrimaryLanguageButtonTitle()
        reloadParallelLanguageButtonTitle()
    }
    
    private func reloadPrimaryLanguageButtonTitle() {
        
        let title: String
        
        if let primaryLanguage = languagesManager.loadPrimaryLanguageFromDisk() {
            title = primaryLanguage.localizedName()
        }
        else {
            title = NSLocalizedString("select_primary_language", comment: "")
        }
        
        primaryLanguageButtonTitle.accept(value: title)
    }
    
    private func reloadParallelLanguageButtonTitle() {
        
        let title: String
        
        // TODO: Would like to replace GTSettings with something more specific here. ~Levi
        if let id = GTSettings.shared.parallelLanguageId, let parallelLanguage = languagesManager.loadFromDisk(id: id) {
            title = parallelLanguage.localizedName()
        }
        else {
            title = NSLocalizedString("select_parallel_language", comment: "")
        }
        
        parallelLanguageButtonTitle.accept(value: title)
    }
    
    func pageViewed() {
        analytics.recordScreenView(screenName: "Language Settings", siteSection: "menu", siteSubSection: "")
    }
    
    func choosePrimaryLanguageTapped() {
        flowDelegate?.navigate(step: .choosePrimaryLanguageTappedFromLanguageSettings)
    }
    
    func chooseParallelLanguageTapped() {
        flowDelegate?.navigate(step: .chooseParallelLanguageTappedFromLanguageSettings)
    }
}
