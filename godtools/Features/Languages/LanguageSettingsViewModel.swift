//
//  LanguageSettingsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LanguageSettingsViewModel: NSObject, LanguageSettingsViewModelType {

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
        
        super.init()
        
        _ = languagesManager.loadPrimaryLanguageFromDisk()
        _ = languagesManager.loadParallelLanguageFromDisk()
        
        languagesManager.primaryLanguage.addObserver(self) { [weak self] (primaryLanguage: Language?) in
            self?.reloadPrimaryLanguageButtonTitle(primaryLanguage: primaryLanguage)
        }
        
        languagesManager.parallelLanguage.addObserver(self) { [weak self] (language: Language?) in
            self?.reloadParallelLanguageButtonTitle(parallelLanguage: language)
        }
    }
    
    deinit {
        languagesManager.primaryLanguage.removeObserver(self)
        languagesManager.parallelLanguage.removeObserver(self)
    }
    
    private func reloadPrimaryLanguageButtonTitle(primaryLanguage: Language?) {
        
        let title: String
        
        if let primaryLanguage = primaryLanguage {
            title = primaryLanguage.localizedName()
        }
        else {
            title = NSLocalizedString("select_primary_language", comment: "")
        }
        
        primaryLanguageButtonTitle.accept(value: title)
    }
    
    private func reloadParallelLanguageButtonTitle(parallelLanguage: Language?) {
        
        let title: String
        
        if let parallelLanguage = parallelLanguage {
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
