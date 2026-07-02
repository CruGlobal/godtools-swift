//
//  LocalizationSettingsFlow.swift
//  godtools
//
//  Created by Levi Eggert on 3/4/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import UIKit
import Combine

final class LocalizationSettingsFlow: GTFlow {
    
    enum CompletedState: Sendable {
        case userTappedBackFromLocalizationSettings
        case userConfirmedLocalizationSetting(country: LocalizationSettingsCountryListItem)
    }
            
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let shouldStoreCountryWhenSelected: Bool
    private let userShouldConfirmSelectedCountry: Bool
        
    init(
        appDiContainer: AppDiContainer,
        shouldStoreCountryWhenSelected: Bool,
        userShouldConfirmSelectedCountry: Bool = true,
        showsPreferNotToSay: Bool = true
    ) {
        
        self.shouldStoreCountryWhenSelected = shouldStoreCountryWhenSelected
        self.userShouldConfirmSelectedCountry = userShouldConfirmSelectedCountry
        
        let stepEmitter = FlowStepEmitter()
        
        super.init(
            appDiContainer: appDiContainer,
            initialView: LocalizationSettingsFlow.getLocalizationSettings(
                appDiContainer: appDiContainer,
                stepEmitter: stepEmitter,
                showsPreferNotToSay: showsPreferNotToSay
            ),
            stepEmitter: stepEmitter
        )
    }
    
    override func navigate(step: FlowStep) {
        
        guard let appStep = step as? AppFlowStep else {
            return
        }

        switch appStep {
            
        case .backTappedFromLocalizationSettings:
            completeFlow(state: .userTappedBackFromLocalizationSettings)
            
        case .countryTappedFromLocalizationSettings(let countryListItem):
            
            if shouldStoreCountryWhenSelected {
                storeSelectedCountryListItem(countryListItem: countryListItem)
            }
            
            if userShouldConfirmSelectedCountry {
               
                presentView(
                    view: getLocalizationSettingsConfirmationView(selectedCountry: countryListItem),
                    animated: true
                )
            }
            
        case .closeTappedFromLocalizationConfirmation:
            dismissView(animated: true)
            
        case .cancelTappedFromLocalizationConfirmation:
            dismissView(animated: true)
            
        case .confirmTappedFromLocalizationConfirmation(let countryListItem):
            
            dismissView(animated: true)
            
            storeSelectedCountryListItem(countryListItem: countryListItem)
            
            completeFlow(state: .userConfirmedLocalizationSetting(country: countryListItem))
            
        default:
            break
        }
    }
    
    private func completeFlow(state: CompletedState) {
        parent?.stepEmitter.emit(step: AppFlowStep.localizationSettingsFlowCompleted(state: state))
    }
    
    private func storeSelectedCountryListItem(countryListItem: LocalizationSettingsCountryListItem) {
        
        appDiContainer
            .feature
            .personalizedTools
            .domainLayer
            .getSetLocalizationSettingsUseCase()
            .execute(country: countryListItem.countryDomainModel)
            .sink { _ in

            } receiveValue: { _ in

            }
            .store(in: &Self.backgroundCancellables)
    }
}

extension LocalizationSettingsFlow {
    
    private static func getLocalizationSettings(appDiContainer: AppDiContainer, stepEmitter: FlowStepEmitter, showsPreferNotToSay: Bool) -> UIViewController {
        
        let viewModel = LocalizationSettingsViewModel(
            stepEmitter: stepEmitter,
            showsPreferNotToSay: showsPreferNotToSay,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getCountryListUseCase: appDiContainer.feature.personalizedTools.domainLayer.getLocalizationSettingsCountryListUseCase(),
            getLocalizationSettingsUseCase: appDiContainer.feature.personalizedTools.domainLayer.getLocalizationSettingsUseCase(),
            searchCountriesUseCase: appDiContainer.feature.personalizedTools.domainLayer.getSearchCountriesInLocalizationSettingsCountriesListUseCase(),
            getLocalizationSettingsStringsUseCase: appDiContainer.feature.personalizedTools.domainLayer.getLocalizationSettingsStringsUseCase(),
            getSearchBarStringsUseCase: appDiContainer.core.domainLayer.getSearchBarStringsUseCase()
        )
        
        let view = LocalizationSettingsView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil
        )
        
        let hostingView = AppHostingController<LocalizationSettingsView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: backButton,
                leadingItems: [],
                trailingItems: []
            )
        )
        
        return hostingView
    }

    private func getLocalizationSettingsConfirmationView(selectedCountry: LocalizationSettingsCountryListItem) -> UIViewController {

        let confirmationViewModel = LocalizationSettingsConfirmationViewModel(
            stepEmitter: stepEmitter,
            selectedCountry: selectedCountry,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getLocalizationSettingsConfirmationStringsUseCase: appDiContainer.feature.personalizedTools.domainLayer.getLocalizationSettingsConfirmationStringsUseCase()
        )

        let confirmationView = LocalizationSettingsConfirmationView(viewModel: confirmationViewModel)

        let hostingView = AppHostingController<LocalizationSettingsConfirmationView>(
            rootView: confirmationView,
            navigationBar: nil
        )

        hostingView.modalPresentationStyle = .overFullScreen
        hostingView.modalTransitionStyle = .crossDissolve
        hostingView.view.backgroundColor = .clear

        return hostingView
    }
}
