//
//  ToolSettingsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class ToolSettingsViewModel: ObservableObject {
        
    private let toolSettingsObserver: ToolSettingsObserver
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewToolSettingsUseCase: ViewToolSettingsUseCase
    private let getShareablesUseCase: GetShareablesUseCase
    private let getShareableImageUseCase: GetShareableImageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var interfaceStrings: ToolSettingsInterfaceStringsDomainModel?
    
    @Published var title: String = ""
    @Published var shareLinkTitle: String = ""
    @Published var screenShareTitle: String = ""
    @Published var trainingTipsIcon: SwiftUI.Image = Image("")
    @Published var trainingTipsTitle: String = ""
    @Published var hidesTrainingTipsButton: Bool = true
    @Published var chooseLanguageTitle: String = ""
    @Published var chooseLanguageToggleMessage: String = ""
    @Published var primaryLanguageTitle: String = ""
    @Published var parallelLanguageTitle: String = ""
    @Published var shareablesTitle: String = ""
    @Published var shareables: [ShareableDomainModel] = Array()
        
    init(flowDelegate: FlowDelegate, toolSettingsObserver: ToolSettingsObserver, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewToolSettingsUseCase: ViewToolSettingsUseCase, getShareablesUseCase: GetShareablesUseCase, getShareableImageUseCase: GetShareableImageUseCase) {
        
        self.flowDelegate = flowDelegate
        self.toolSettingsObserver = toolSettingsObserver
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewToolSettingsUseCase = viewToolSettingsUseCase
        self.getShareablesUseCase = getShareablesUseCase
        self.getShareableImageUseCase = getShareableImageUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        Publishers.CombineLatest(
            $appLanguage.eraseToAnyPublisher(),
            toolSettingsObserver.$languages.eraseToAnyPublisher()
        )
        .flatMap ({ (appLanguage: AppLanguageDomainModel, languages: ToolSettingsLanguages) -> AnyPublisher<ViewToolSettingsDomainModel, Never> in
            
            return viewToolSettingsUseCase
                .viewPublisher(
                    appLanguage: appLanguage,
                    toolId: toolSettingsObserver.toolId,
                    toolLanguageId: languages.selectedLanguageId,
                    toolPrimaryLanguageId: languages.primaryLanguageId,
                    toolParallelLanguageId: languages.parallelLanguageId
                )
                .eraseToAnyPublisher()
        })
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (domainModel: ViewToolSettingsDomainModel) in
                        
            self?.title = domainModel.interfaceStrings.title
            self?.shareLinkTitle = domainModel.interfaceStrings.toolOptionShareLink
            self?.screenShareTitle = domainModel.interfaceStrings.toolOptionScreenShare
            self?.chooseLanguageTitle = domainModel.interfaceStrings.languageSelectionTitle
            self?.chooseLanguageToggleMessage = domainModel.interfaceStrings.languageSelectionMessage
            self?.shareablesTitle = domainModel.interfaceStrings.relatedGraphicsTitle
            
            self?.hidesTrainingTipsButton = !domainModel.hasTips
            
            self?.interfaceStrings = domainModel.interfaceStrings
                            
            self?.primaryLanguageTitle = domainModel.primaryLanguage?.languageName ?? ""
            self?.parallelLanguageTitle = domainModel.parallelLanguage?.languageName ?? domainModel.interfaceStrings.chooseParallelLanguageActionTitle
        }
        .store(in: &cancellables)

        Publishers.CombineLatest(
            toolSettingsObserver.$trainingTipsEnabled.eraseToAnyPublisher(),
            $interfaceStrings.eraseToAnyPublisher()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (trainingTipsEnabled: Bool, interfaceStrings: ToolSettingsInterfaceStringsDomainModel?) in
            
            guard let interfaceStrings = interfaceStrings else {
                return
            }
            
            self?.trainingTipsTitle = trainingTipsEnabled ? interfaceStrings.toolOptionDisableTrainingTips : interfaceStrings.toolOptionEnableTrainingTips
            self?.trainingTipsIcon = trainingTipsEnabled ? ImageCatalog.toolSettingsOptionHideTips.image : ImageCatalog.toolSettingsOptionTrainingTips.image
        }
        .store(in: &cancellables)
        
        toolSettingsObserver.$languages.eraseToAnyPublisher()
            .flatMap({ (languages: ToolSettingsLanguages) -> AnyPublisher<[ShareableDomainModel], Never> in
                
                return getShareablesUseCase
                    .getShareablesPublisher(toolId: toolSettingsObserver.toolId, toolLanguageId: languages.selectedLanguageId)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .assign(to: &$shareables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension ToolSettingsViewModel {
    
    func getShareableItemViewModel(shareable: ShareableDomainModel) -> ToolSettingsShareableItemViewModel {
        
        return ToolSettingsShareableItemViewModel(
            shareable: shareable,
            getShareableImageUseCase: getShareableImageUseCase
        )
    }
    
    func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromToolSettings)
    }
    
    func shareLinkTapped() {
        
        flowDelegate?.navigate(step: .shareLinkTappedFromToolSettings)
    }
    
    func screenShareTapped() {
        
        flowDelegate?.navigate(step: .screenShareTappedFromToolSettings)
    }
    
    func trainingTipsTapped() {

        let trainingTipsEnabled: Bool = !toolSettingsObserver.trainingTipsEnabled
               
        toolSettingsObserver.trainingTipsEnabled = trainingTipsEnabled
    }
    
    func primaryLanguageTapped() {
        
        flowDelegate?.navigate(step: .primaryLanguageTappedFromToolSettings)
    }
    
    func parallelLanguageTapped() {
        
        flowDelegate?.navigate(step: .parallelLanguageTappedFromToolSettings)
    }
    
    func swapLanguageTapped() {

        let primaryLanguageId: String? = toolSettingsObserver.languages.primaryLanguageId
        let parallelLanguageId: String? = toolSettingsObserver.languages.parallelLanguageId
        let selectedLanguageId: String = toolSettingsObserver.languages.selectedLanguageId
                
        guard let primaryLanguageId = primaryLanguageId, let parallelLanguageId = parallelLanguageId else {
            return
        }
        
        toolSettingsObserver.languages = ToolSettingsLanguages(
            primaryLanguageId: parallelLanguageId,
            parallelLanguageId: primaryLanguageId,
            selectedLanguageId: selectedLanguageId
        )
    }
    
    func shareableTapped(shareable: ShareableDomainModel) {
        
        flowDelegate?.navigate(step: .shareableTappedFromToolSettings(shareable: shareable))
    }
}
