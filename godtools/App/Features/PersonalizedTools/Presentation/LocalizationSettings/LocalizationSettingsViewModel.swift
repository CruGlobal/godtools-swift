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
    
    private let countryDummyData = [
        LocalizationSettingsCountryDomainModel(countryNameTranslatedInOwnLanguage: "US", countryNameTranslatedInCurrentAppLanguage: "US"),
        LocalizationSettingsCountryDomainModel(countryNameTranslatedInOwnLanguage: "Ngola", countryNameTranslatedInCurrentAppLanguage: "Angola"),
        LocalizationSettingsCountryDomainModel(countryNameTranslatedInOwnLanguage: "Argentina", countryNameTranslatedInCurrentAppLanguage: "Argentina"),
        LocalizationSettingsCountryDomainModel(countryNameTranslatedInOwnLanguage: "Hayastan", countryNameTranslatedInCurrentAppLanguage: "Armenia"),
        LocalizationSettingsCountryDomainModel(countryNameTranslatedInOwnLanguage: "Osterreich", countryNameTranslatedInCurrentAppLanguage: "Austria")
    ]
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewSearchBarUseCase: ViewSearchBarUseCase

    private var cancellables: Set<AnyCancellable> = Set()

    private weak var flowDelegate: FlowDelegate?
    private lazy var searchBarViewModel = SearchBarViewModel(getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, viewSearchBarUseCase: viewSearchBarUseCase)

    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var countriesList: [LocalizationSettingsCountryDomainModel] = Array()
    
    @Published var searchText: String = ""
    @Published var countrySearchResults: [LocalizationSettingsCountryDomainModel] = Array()
    @Published var navTitle: String = ""

    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewSearchBarUseCase: ViewSearchBarUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewSearchBarUseCase = viewSearchBarUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        // TODO: - get real data
        countriesList = countryDummyData
        countrySearchResults = countryDummyData
        
        // TODO: - set up search bar
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
        
        // TODO
    }
    
    func getSearchBarViewModel() -> SearchBarViewModel {
        
        return searchBarViewModel
    }
}
