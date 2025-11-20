//
//  PersonalizedToolsCountrySelectionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit
import Combine

class PersonalizedToolsCountrySelectionViewModel: ObservableObject {
    
    private let countryDummyData = [
        PersonalizedToolsCountryDomainModel(countryNameTranslatedInOwnLanguage: "US", countryNameTranslatedInCurrentAppLanguage: "US"),
        PersonalizedToolsCountryDomainModel(countryNameTranslatedInOwnLanguage: "Ngola", countryNameTranslatedInCurrentAppLanguage: "Angola"),
        PersonalizedToolsCountryDomainModel(countryNameTranslatedInOwnLanguage: "Argentina", countryNameTranslatedInCurrentAppLanguage: "Argentina"),
        PersonalizedToolsCountryDomainModel(countryNameTranslatedInOwnLanguage: "Hayastan", countryNameTranslatedInCurrentAppLanguage: "Armenia"),
        PersonalizedToolsCountryDomainModel(countryNameTranslatedInOwnLanguage: "Osterreich", countryNameTranslatedInCurrentAppLanguage: "Austria")
    ]
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewSearchBarUseCase: ViewSearchBarUseCase

    private var cancellables: Set<AnyCancellable> = Set()

    private weak var flowDelegate: FlowDelegate?
    private lazy var searchBarViewModel = SearchBarViewModel(getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, viewSearchBarUseCase: viewSearchBarUseCase)

    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var countriesList: [PersonalizedToolsCountryDomainModel] = Array()
    
    @Published var searchText: String = ""
    @Published var countrySearchResults: [PersonalizedToolsCountryDomainModel] = Array()
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

extension PersonalizedToolsCountrySelectionViewModel {
    
    @objc func backTapped() {
        flowDelegate?.navigate(step: .backTappedFromLocalizationSettings)
    }
    
    func countryTapped(country: PersonalizedToolsCountryDomainModel) {
        
        // TODO
    }
    
    func getSearchBarViewModel() -> SearchBarViewModel {
        
        return searchBarViewModel
    }
}
