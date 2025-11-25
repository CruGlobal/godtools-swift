//
//  LocalizationSettingsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit
import Combine

class LocalizationSettingsViewModel: ObservableObject {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getCountryListUseCase: GetLocalizationSettingsCountryListUseCase
    private let viewLocalizationSettingsUseCase: ViewLocalizationSettingsUseCase
    private let viewSearchBarUseCase: ViewSearchBarUseCase

    private var cancellables: Set<AnyCancellable> = Set()

    private weak var flowDelegate: FlowDelegate?
    private lazy var searchBarViewModel = SearchBarViewModel(getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, viewSearchBarUseCase: viewSearchBarUseCase)

    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var countriesList: [LocalizationSettingsCountryDomainModel] = Array()
    
    @Published var searchText: String = ""
    @Published var countrySearchResults: [LocalizationSettingsCountryDomainModel] = Array()
    @Published var navTitle: String = ""
    @Published var localizationHeaderTitle: String = ""
    @Published var localizationHeaderDescription: String = ""

    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getCountryListUseCase: GetLocalizationSettingsCountryListUseCase, viewLocalizationSettingsUseCase: ViewLocalizationSettingsUseCase, viewSearchBarUseCase: ViewSearchBarUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getCountryListUseCase = getCountryListUseCase
        self.viewLocalizationSettingsUseCase = viewLocalizationSettingsUseCase
        self.viewSearchBarUseCase = viewSearchBarUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { appLanguage in
                getCountryListUseCase.execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .assign(to: &$countriesList)
        
        $appLanguage
            .dropFirst()
            .map { appLanguage in
                viewLocalizationSettingsUseCase.execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] domainModel in
                
                self?.navTitle = domainModel.navTitle
                self?.localizationHeaderTitle = domainModel.localizationHeaderTitle
                self?.localizationHeaderDescription = domainModel.localizationHeaderDescription
            }
            .store(in: &cancellables)
        
        // TODO: - set up search bar
        $countriesList
            .assign(to: &$countrySearchResults)
    }
    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension LocalizationSettingsViewModel {
    
    @objc func backTapped() {
        flowDelegate?.navigate(step: .backTappedFromLocalizationSettings)
    }
    
    func countryTapped(country: LocalizationSettingsCountryDomainModel) {
        
        // TODO: -
    }
    
    func getSearchBarViewModel() -> SearchBarViewModel {
        
        return searchBarViewModel
    }
}
