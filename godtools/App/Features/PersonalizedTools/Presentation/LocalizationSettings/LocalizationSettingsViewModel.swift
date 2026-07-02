//
//  LocalizationSettingsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit
import Combine

@MainActor
final class LocalizationSettingsViewModel: ObservableObject {
    
    private let stepEmitter: FlowStepEmitter
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getCountryListUseCase: GetLocalizationSettingsCountryListUseCase
    private let getLocalizationSettingsUseCase: GetLocalizationSettingsUseCase
    private let searchCountriesUseCase: SearchCountriesInLocalizationSettingsCountriesListUseCase
    private let getLocalizationSettingsStringsUseCase: GetLocalizationSettingsStringsUseCase
    private let getSearchBarStringsUseCase: GetSearchBarStringsUseCase

    private var cancellables: Set<AnyCancellable> = Set()

    @Published private var appLanguage = AppLanguageDomainModel.english
    @Published private var countriesList: [LocalizationSettingsCountryListItem] = Array()
    
    @Published private(set) var selectedCountryIsoRegionCode: String?
    @Published private(set) var countrySearchResults: [LocalizationSettingsCountryListItem] = Array()
    @Published private(set) var searchBarStrings = SearchBarStringsDomainModel.emptyValue
    @Published private(set) var strings = LocalizationSettingsStringsDomainModel.emptyValue
    
    @Published var searchText: String = ""

    init(
        stepEmitter: FlowStepEmitter,
        showsPreferNotToSay: Bool,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getCountryListUseCase: GetLocalizationSettingsCountryListUseCase,
        getLocalizationSettingsUseCase: GetLocalizationSettingsUseCase,
        searchCountriesUseCase: SearchCountriesInLocalizationSettingsCountriesListUseCase,
        getLocalizationSettingsStringsUseCase: GetLocalizationSettingsStringsUseCase,
        getSearchBarStringsUseCase: GetSearchBarStringsUseCase
    ) {

        self.stepEmitter = stepEmitter
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getCountryListUseCase = getCountryListUseCase
        self.getLocalizationSettingsUseCase = getLocalizationSettingsUseCase
        self.searchCountriesUseCase = searchCountriesUseCase
        self.getLocalizationSettingsStringsUseCase = getLocalizationSettingsStringsUseCase
        self.getSearchBarStringsUseCase = getSearchBarStringsUseCase

        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appLanguage: AppLanguageDomainModel) in
                self?.appLanguage = appLanguage
                self?.didSetApplanguage(appLanguage: appLanguage)
            }
            .store(in: &cancellables)

        getLocalizationSettingsUseCase.execute()
            .map { domainModel in
                return domainModel?.selectedCountry.isoRegionCode
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$selectedCountryIsoRegionCode)

        $appLanguage
            .dropFirst()
            .map { appLanguage in
                getCountryListUseCase
                    .execute(
                        appLanguage: appLanguage,
                        showsPreferNotToSay: showsPreferNotToSay
                    )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (countriesList: [LocalizationSettingsCountryListItem]) in
                
                self?.countriesList = countriesList
            })
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $searchText,
            $countriesList.dropFirst()
        )
        .map { (searchText, countriesList) in
            return AnyPublisher() {
                await searchCountriesUseCase.execute(
                    searchText: searchText,
                    countriesList: countriesList
                )
            }
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .assign(to: &$countrySearchResults)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func didSetApplanguage(appLanguage: AppLanguageDomainModel) {
        
        searchBarStrings = getSearchBarStringsUseCase
            .execute(appLanguage: appLanguage)
        
        strings = getLocalizationSettingsStringsUseCase
            .execute(appLanguage: appLanguage)
    }
}

// MARK: - Inputs

extension LocalizationSettingsViewModel {
    
    @objc func backTapped() {
        stepEmitter.emit(step: AppFlowStep.backTappedFromLocalizationSettings)
    }
    
    func countryTapped(country: LocalizationSettingsCountryListItem) {
        stepEmitter.emit(step: AppFlowStep.countryTappedFromLocalizationSettings(country: country))
    }
}
