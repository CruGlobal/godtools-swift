//
//  ToolSettingsViewModel.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/11/22.
//

import Foundation
import GodToolsToolParser
import Combine

class ToolSettingsViewModel: BaseToolSettingsViewModel {
    
    private let manifestResourcesCache: ManifestResourcesCache
    private let localizationServices: LocalizationServices
    private let primaryLanguageSubject: CurrentValueSubject<LanguageModel, Never>
    private let parallelLanguageSubject: CurrentValueSubject<LanguageModel?, Never>
    private let trainingTipsEnabled: Bool
    private let shareables: [Shareable]
    
    private weak var flowDelegate: FlowDelegate?
        
    required init(flowDelegate: FlowDelegate, manifestResourcesCache: ManifestResourcesCache, localizationServices: LocalizationServices, primaryLanguageSubject: CurrentValueSubject<LanguageModel, Never>, parallelLanguageSubject: CurrentValueSubject<LanguageModel?, Never>, trainingTipsEnabled: Bool, shareables: [Shareable]) {
        
        self.flowDelegate = flowDelegate
        self.manifestResourcesCache = manifestResourcesCache
        self.localizationServices = localizationServices
        self.primaryLanguageSubject = primaryLanguageSubject
        self.parallelLanguageSubject = parallelLanguageSubject
        self.trainingTipsEnabled = trainingTipsEnabled
        self.shareables = shareables
    }
    
    override func getTopBarViewModel() -> BaseToolSettingsTopBarViewModel {
        
        guard let flowDelegate = flowDelegate else {
            assertionFailure("Failed to instantiate viewModel, flowDelegate should not be nil.")
            return BaseToolSettingsTopBarViewModel()
        }

        return ToolSettingsTopBarViewModel(flowDelegate: flowDelegate)
    }
    
    override func getOptionsViewModel() -> BaseToolSettingsOptionsViewModel {
        
        guard let flowDelegate = flowDelegate else {
            assertionFailure("Failed to instantiate viewModel, flowDelegate should not be nil.")
            return BaseToolSettingsOptionsViewModel()
        }
        
        return ToolSettingsOptionsViewModel(flowDelegate: flowDelegate, trainingTipsEnabled: trainingTipsEnabled)
    }
    
    override func getChooseLanguageViewModel() -> BaseToolSettingsChooseLanguageViewModel {
        
        guard let flowDelegate = flowDelegate else {
            assertionFailure("Failed to instantiate viewModel, flowDelegate should not be nil.")
            return BaseToolSettingsChooseLanguageViewModel()
        }
        
        return ToolSettingsChooseLanguageViewModel(
            flowDelegate: flowDelegate,
            localizationServices: localizationServices,
            primaryLanguageSubject: primaryLanguageSubject,
            parallelLanguageSubject: parallelLanguageSubject
        )
    }
    
    override func getShareablesViewModel() -> BaseToolSettingsShareablesViewModel {
        
        guard let flowDelegate = flowDelegate else {
            assertionFailure("Failed to instantiate viewModel, flowDelegate should not be nil.")
            return BaseToolSettingsShareablesViewModel()
        }
        
        return ToolSettingsShareablesViewModel(flowDelegate: flowDelegate, shareables: shareables, manifestResourcesCache: manifestResourcesCache)
    }
}
