//
//  ToolSettingsViewModel.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/11/22.
//

import Foundation
import GodToolsToolParser

class ToolSettingsViewModel: BaseToolSettingsViewModel {
    
    private let manifestResourcesCache: ManifestResourcesCache
    private let localizationServices: LocalizationServices
    private let primaryLanguage: LanguageModel
    private let parallelLanguage: LanguageModel?
    private let trainingTipsEnabled: Bool
    private let shareables: [Shareable]
    
    private weak var flowDelegate: FlowDelegate?
        
    required init(flowDelegate: FlowDelegate, manifestResourcesCache: ManifestResourcesCache, localizationServices: LocalizationServices, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?, trainingTipsEnabled: Bool, shareables: [Shareable]) {
        
        self.flowDelegate = flowDelegate
        self.manifestResourcesCache = manifestResourcesCache
        self.localizationServices = localizationServices
        self.primaryLanguage = primaryLanguage
        self.parallelLanguage = parallelLanguage
        self.trainingTipsEnabled = trainingTipsEnabled
        self.shareables = shareables
        
        super.init()        
    }
    
    override func getTopBarViewModel() -> BaseToolSettingsTopBarViewModel {
        
        guard let flowDelegate = flowDelegate else {
            assertionFailure("Failed to instantiate viewModel, flowDelegate should not be nil.")
            return BaseToolSettingsTopBarViewModel()
        }

        return ToolSettingsTopBarViewModel(
            flowDelegate: flowDelegate,
            localizationServices: localizationServices
        )
    }
    
    override func getOptionsViewModel() -> BaseToolSettingsOptionsViewModel {
        
        guard let flowDelegate = flowDelegate else {
            assertionFailure("Failed to instantiate viewModel, flowDelegate should not be nil.")
            return BaseToolSettingsOptionsViewModel()
        }
        
        return ToolSettingsOptionsViewModel(
            flowDelegate: flowDelegate,
            localizationServices: localizationServices,
            trainingTipsEnabled: trainingTipsEnabled
        )
    }
    
    override func getChooseLanguageViewModel() -> BaseToolSettingsChooseLanguageViewModel {
        
        guard let flowDelegate = flowDelegate else {
            assertionFailure("Failed to instantiate viewModel, flowDelegate should not be nil.")
            return BaseToolSettingsChooseLanguageViewModel()
        }
        
        return ToolSettingsChooseLanguageViewModel(
            flowDelegate: flowDelegate,
            localizationServices: localizationServices,
            primaryLanguage: primaryLanguage,
            parallelLanguage: parallelLanguage
        )
    }
    
    override func getShareablesViewModel() -> BaseToolSettingsShareablesViewModel {
        
        guard let flowDelegate = flowDelegate else {
            assertionFailure("Failed to instantiate viewModel, flowDelegate should not be nil.")
            return BaseToolSettingsShareablesViewModel()
        }
        
        return ToolSettingsShareablesViewModel(
            flowDelegate: flowDelegate,
            shareables: shareables,
            manifestResourcesCache: manifestResourcesCache,
            localizationServices: localizationServices
        )
    }
}
