//
//  ParallelLanguageListViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 12/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ParallelLanguageListViewModel: ParallelLanguageListViewModelType {
    
    private let getLanguagesListUseCase: GetLanguagesListUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let userDidSetSettingsParallelLanguageUseCase: UserDidSetSettingsParallelLanguageUseCase
    private let localizationServices: LocalizationServices
    
    private var languagesList: [LanguageDomainModel] = Array()
    private var cancellables = Set<AnyCancellable>()
    
    private weak var flowDelegate: FlowDelegate?
    
    let selectButtonText: String
    let numberOfLanguages: ObservableValue<Int>
    
    required init(flowDelegate: FlowDelegate, getLanguagesListUseCase: GetLanguagesListUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, userDidSetSettingsParallelLanguageUseCase: UserDidSetSettingsParallelLanguageUseCase, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.getLanguagesListUseCase = getLanguagesListUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.userDidSetSettingsParallelLanguageUseCase = userDidSetSettingsParallelLanguageUseCase
        self.localizationServices = localizationServices
        
        selectButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.selectButton.title")
        numberOfLanguages = ObservableValue(value: 0)
        
        Publishers.CombineLatest(getLanguagesListUseCase.getLanguagesList(), getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher())
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
    
    func languageWillAppear(index: Int) -> ChooseLanguageCellViewModel {
        
        let language: LanguageDomainModel = languagesList[index]
        
        return ChooseLanguageCellViewModel(
            language: language,
            languageIsDownloaded: true, //hides downloadImageView for all cells in this list
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
