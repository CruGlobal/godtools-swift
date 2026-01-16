//
//  LocalizationSettingsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit
import Combine

@MainActor class LocalizationSettingsViewModel: ObservableObject {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getCountryListUseCase: GetLocalizationSettingsCountryListUseCase
    private let searchCountriesUseCase: SearchCountriesInLocalizationSettingsCountriesListUseCase
    private let setLocalizationSettingUseCase: SetLocalizationSettingUseCase
    private let viewLocalizationSettingsUseCase: ViewLocalizationSettingsUseCase
    private let viewSearchBarUseCase: ViewSearchBarUseCase

    private var cancellables: Set<AnyCancellable> = Set()

    private weak var flowDelegate: FlowDelegate?
    private lazy var searchBarViewModel = SearchBarViewModel(getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, viewSearchBarUseCase: viewSearchBarUseCase)

    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var countriesList: [LocalizationSettingsCountryDomainModel] = Array()
    
    @Published var searchText: String = ""
    @Published private(set) var countrySearchResults: [LocalizationSettingsCountryDomainModel] = Array()
    @Published private(set) var strings = LocalizationSettingsInterfaceStringsDomainModel.emptyValue

    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getCountryListUseCase: GetLocalizationSettingsCountryListUseCase, searchCountriesUseCase: SearchCountriesInLocalizationSettingsCountriesListUseCase, setLocalizationSettingUseCase: SetLocalizationSettingUseCase, viewLocalizationSettingsUseCase: ViewLocalizationSettingsUseCase, viewSearchBarUseCase: ViewSearchBarUseCase) {

        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getCountryListUseCase = getCountryListUseCase
        self.searchCountriesUseCase = searchCountriesUseCase
        self.setLocalizationSettingUseCase = setLocalizationSettingUseCase
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
            .assign(to: &$strings)
        
        Publishers.CombineLatest(
            $searchText,
            $countriesList.dropFirst()
        )
        .flatMap { (searchText, countriesList) in
            
            searchCountriesUseCase.execute(searchText: searchText, in: countriesList)
        }
        .receive(on: DispatchQueue.main)
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

        setLocalizationSettingUseCase.execute(isoRegionCode: country.isoRegionCode)
            .sink { _ in }
            .store(in: &cancellables)
    }
    
    func getSearchBarViewModel() -> SearchBarViewModel {
        
        return searchBarViewModel
    }
}
