//
//  LocalizationSettingsConfirmationViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class LocalizationSettingsConfirmationViewModel: ObservableObject {

    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let localizationServices: LocalizationServicesInterface
    private var cancellables: Set<AnyCancellable> = Set()

    private weak var flowDelegate: FlowDelegate?

    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private(set) var strings = LocalizationSettingsConfirmationStringsDomainModel.emptyValue

    let selectedCountry: LocalizationSettingsCountryListItemDomainModel

    init(flowDelegate: FlowDelegate, selectedCountry: LocalizationSettingsCountryListItemDomainModel, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, localizationServices: LocalizationServicesInterface) {

        self.flowDelegate = flowDelegate
        self.selectedCountry = selectedCountry
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.localizationServices = localizationServices

        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)

        $appLanguage
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] appLanguage in
                self?.loadStrings(appLanguage: appLanguage)
            }
            .store(in: &cancellables)
    }

    private func loadStrings(appLanguage: AppLanguageDomainModel) {

        strings = LocalizationSettingsConfirmationStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "localizationSettings.confirmation.title"),
            description: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "localizationSettings.confirmation.description"),
            detail: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "localizationSettings.confirmation.detail"),
            cancelButton: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "localizationSettings.confirmation.cancelButton"),
            confirmButton: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "localizationSettings.confirmation.confirmButton")
        )
    }

    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension LocalizationSettingsConfirmationViewModel {

    func closeTapped() {
        flowDelegate?.navigate(step: .closeLocalizationConfirmationFromLocalizationSettings)
    }

    func cancelTapped() {
        flowDelegate?.navigate(step: .cancelLocalizationConfirmationFromLocalizationSettings)
    }

    func confirmTapped() {
        flowDelegate?.navigate(step: .confirmLocalizationConfirmationFromLocalizationSettings(country: selectedCountry))
    }
}
