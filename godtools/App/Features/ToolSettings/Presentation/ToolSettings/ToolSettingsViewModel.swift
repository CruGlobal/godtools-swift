//
//  ToolSettingsViewModel.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/11/22.
//

import Foundation
import GodToolsToolParser
import Combine

class ToolSettingsViewModel: ObservableObject {
    
    private let manifestResourcesCache: ManifestResourcesCache
    private let localizationServices: LocalizationServices
    private let primaryLanguageSubject: CurrentValueSubject<LanguageModel, Never>
    private let parallelLanguageSubject: CurrentValueSubject<LanguageModel?, Never>
    private let trainingTipsEnabled: Bool
    private let shareables: [Shareable]
    
    private var primaryLanguageCancellable: AnyCancellable?
    private var parallelLanguageCancellable: AnyCancellable?
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var chooseLanguageTitle: String = ""
    @Published var primaryLanguageTitle: String = ""
    @Published var parallelLanguageTitle: String = ""
    @Published var hidesShareables: Bool = false
        
    required init(flowDelegate: FlowDelegate, manifestResourcesCache: ManifestResourcesCache, localizationServices: LocalizationServices, primaryLanguageSubject: CurrentValueSubject<LanguageModel, Never>, parallelLanguageSubject: CurrentValueSubject<LanguageModel?, Never>, trainingTipsEnabled: Bool, shareables: [Shareable]) {
        
        self.flowDelegate = flowDelegate
        self.manifestResourcesCache = manifestResourcesCache
        self.localizationServices = localizationServices
        self.primaryLanguageSubject = primaryLanguageSubject
        self.parallelLanguageSubject = parallelLanguageSubject
        self.trainingTipsEnabled = trainingTipsEnabled
        self.shareables = shareables
        chooseLanguageTitle = localizationServices.stringForMainBundle(key: "toolSettings.chooseLanguage.title")
        hidesShareables = shareables.isEmpty
        
        primaryLanguageCancellable = primaryLanguageSubject.sink(receiveValue: { [weak self] (language: LanguageModel) in
            
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.primaryLanguageTitle = weakSelf.getTranslatedLanguageName(language: language)
        })
        
        parallelLanguageCancellable = parallelLanguageSubject.sink(receiveValue: { [weak self] (language: LanguageModel?) in
            
            guard let weakSelf = self else {
                return
            }
            
            if let language = language {
                weakSelf.parallelLanguageTitle = weakSelf.getTranslatedLanguageName(language: language)
            }
            else {
                weakSelf.parallelLanguageTitle = weakSelf.localizationServices.stringForMainBundle(key: "toolSettings.chooseLanguage.noParallelLanguageTitle")
            }
        })
    }
    
    func getTopBarViewModel() -> BaseToolSettingsTopBarViewModel {
        
        guard let flowDelegate = flowDelegate else {
            assertionFailure("Failed to instantiate viewModel, flowDelegate should not be nil.")
            return BaseToolSettingsTopBarViewModel()
        }

        return ToolSettingsTopBarViewModel(
            flowDelegate: flowDelegate,
            localizationServices: localizationServices
        )
    }
    
    func getOptionsViewModel() -> BaseToolSettingsOptionsViewModel {
        
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
    
    func getShareablesViewModel() -> BaseToolSettingsShareablesViewModel {
        
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
    
    private func getTranslatedLanguageName(language: LanguageModel) -> String {
        return LanguageViewModel(language: language, localizationServices: localizationServices).translatedLanguageName
    }
    
    func primaryLanguageTapped() {
        
        flowDelegate?.navigate(step: .primaryLanguageTappedFromToolSettings)
    }
    
    func parallelLanguageTapped() {
        
        flowDelegate?.navigate(step: .parallelLanguageTappedFromToolSettings)
    }
    
    func swapLanguageTapped() {
        
        flowDelegate?.navigate(step: .swapLanguagesTappedFromToolSettings)
    }
}
