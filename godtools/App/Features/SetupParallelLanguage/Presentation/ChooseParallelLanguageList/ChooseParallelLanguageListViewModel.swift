//
//  ChooseParallelLanguageListViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 12/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ChooseParallelLanguageListViewModel {
    
    private let getSettingsLanguagesUseCase: GetSettingsLanguagesUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let userDidSetSettingsParallelLanguageUseCase: UserDidSetSettingsParallelLanguageUseCase
    private let localizationServices: LocalizationServices
    
    private var languagesList: [LanguageDomainModel] = Array()
    private var cancellables = Set<AnyCancellable>()
    
    private weak var flowDelegate: FlowDelegate?
    
    let selectButtonText: String
    let numberOfLanguages: ObservableValue<Int>
    
    init(flowDelegate: FlowDelegate, getSettingsLanguagesUseCase: GetSettingsLanguagesUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, userDidSetSettingsParallelLanguageUseCase: UserDidSetSettingsParallelLanguageUseCase, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.getSettingsLanguagesUseCase = getSettingsLanguagesUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.userDidSetSettingsParallelLanguageUseCase = userDidSetSettingsParallelLanguageUseCase
        self.localizationServices = localizationServices
        
        selectButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.selectButton.title")
        numberOfLanguages = ObservableValue(value: 0)
        
        Publishers.CombineLatest(getSettingsLanguagesUseCase.getLanguagesList(), getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (languages, settingsPrimaryLanguage) in
                self?.setLanguagesList(languages: languages, settingsPrimaryLanguage: settingsPrimaryLanguage)
            }
            .store(in: &cancellables)
    }
    
    private func setLanguagesList(languages: [LanguageDomainModel], settingsPrimaryLanguage: LanguageDomainModel?) {
                
        languagesList = languages.filter({$0.dataModelId != settingsPrimaryLanguage?.dataModelId})
        
        languagesList = languages
        
        numberOfLanguages.accept(value: languagesList.count)
    }
}

// MARK: - Inputs

extension ChooseParallelLanguageListViewModel {
    
    func languageWillAppear(index: Int) -> ChooseLanguageCellViewModel {
        
        let language: LanguageDomainModel = languagesList[index]
        
        return ChooseLanguageCellViewModel(
            language: language,
            hidesSelected: true,
            selectorColor: UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0),
            separatorColor: UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0),
            separatorLeftInset: 24,
            separatorRightInset: 24,
            languageLabelFontSize: 14
        )
    }
    
    func languageTapped(index: Int) {
                
        let selectedLanguage: LanguageDomainModel = languagesList[index]
        
        userDidSetSettingsParallelLanguageUseCase.setParallelLanguage(language: selectedLanguage)
        
        flowDelegate?.navigate(step: .languageSelectedFromParallelLanguageList)
    }
}
