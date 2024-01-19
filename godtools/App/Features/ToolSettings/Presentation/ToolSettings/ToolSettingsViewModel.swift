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
    
    private static var setToolSettingsPrimaryLanguageCancellable: AnyCancellable?
    private static var setToolSettingsParallelLanguageCancellable: AnyCancellable?
    
    private let tool: ResourceModel
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewToolSettingsUseCase: ViewToolSettingsUseCase
    private let getToolSettingsPrimaryLanguageUseCase: GetToolSettingsPrimaryLanguageUseCase
    private let setToolSettingsPrimaryLanguageUseCase: SetToolSettingsPrimaryLanguageUseCase
    private let setToolSettingsParallelLanguageUseCase: SetToolSettingsParallelLanguageUseCase
    private let getShareablesUseCase: GetShareablesUseCase
    private let getShareableImageUseCase: GetShareableImageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var viewToolSettings: ViewToolSettingsDomainModel?
    @Published private var interfaceStrings: ToolSettingsInterfaceStringsDomainModel?
    @Published private var trainingTipsEnabled: Bool = false
    @Published private var primaryLanguage: ToolSettingsToolLanguageDomainModel?
    
    @Published var title: String = ""
    @Published var shareLinkTitle: String = ""
    @Published var screenShareTitle: String = ""
    @Published var trainingTipsIcon: SwiftUI.Image = Image("")
    @Published var trainingTipsTitle: String = ""
    @Published var hidesToggleTrainingTipsButton: Bool = false
    @Published var chooseLanguageTitle: String = ""
    @Published var chooseLanguageToggleMessage: String = ""
    @Published var primaryLanguageTitle: String = ""
    @Published var parallelLanguageTitle: String = ""
    @Published var shareablesTitle: String = ""
    @Published var shareables: [ShareableDomainModel] = Array()
        
    init(flowDelegate: FlowDelegate, tool: ResourceModel, toolPrimaryLanguage: LanguageDomainModel, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewToolSettingsUseCase: ViewToolSettingsUseCase, getToolSettingsPrimaryLanguageUseCase: GetToolSettingsPrimaryLanguageUseCase, setToolSettingsPrimaryLanguageUseCase: SetToolSettingsPrimaryLanguageUseCase, setToolSettingsParallelLanguageUseCase: SetToolSettingsParallelLanguageUseCase, getShareablesUseCase: GetShareablesUseCase, getShareableImageUseCase: GetShareableImageUseCase, trainingTipsEnabled: Bool) {
        
        self.flowDelegate = flowDelegate
        self.tool = tool
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewToolSettingsUseCase = viewToolSettingsUseCase
        self.getToolSettingsPrimaryLanguageUseCase = getToolSettingsPrimaryLanguageUseCase
        self.setToolSettingsPrimaryLanguageUseCase = setToolSettingsPrimaryLanguageUseCase
        self.setToolSettingsParallelLanguageUseCase = setToolSettingsParallelLanguageUseCase
        self.getShareablesUseCase = getShareablesUseCase
        self.getShareableImageUseCase = getShareableImageUseCase
        self.trainingTipsEnabled = trainingTipsEnabled
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        getToolSettingsPrimaryLanguageUseCase
            .getLanguagePublisher(translateInLanguage: appLanguage)
            .assign(to: &$primaryLanguage)
        
        Publishers.CombineLatest(
            $appLanguage.eraseToAnyPublisher(),
            $primaryLanguage.eraseToAnyPublisher()
        )
        .flatMap ({ (appLanguage: AppLanguageDomainModel, primaryLanguage: ToolSettingsToolLanguageDomainModel?) -> AnyPublisher<ViewToolSettingsDomainModel, Never> in
            
            return viewToolSettingsUseCase
                .viewPublisher(appLanguage: appLanguage, tool: tool, toolLanguage: primaryLanguage)
                .eraseToAnyPublisher()
        })
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (domainModel: ViewToolSettingsDomainModel) in
            
            self?.viewToolSettings = domainModel
            
            self?.title = domainModel.interfaceStrings.title
            self?.shareLinkTitle = domainModel.interfaceStrings.toolOptionShareLink
            self?.screenShareTitle = domainModel.interfaceStrings.toolOptionScreenShare
            self?.chooseLanguageTitle = domainModel.interfaceStrings.languageSelectionTitle
            self?.chooseLanguageToggleMessage = domainModel.interfaceStrings.languageSelectionMessage
            self?.shareablesTitle = domainModel.interfaceStrings.relatedGraphicsTitle
            
            self?.hidesToggleTrainingTipsButton = !domainModel.hasTips
            
            self?.interfaceStrings = domainModel.interfaceStrings
                            
            self?.primaryLanguageTitle = domainModel.primaryLanguage?.languageName ?? ""
            self?.parallelLanguageTitle = domainModel.parallelLanguage?.languageName ?? domainModel.interfaceStrings.chooseParallelLanguageActionTitle
        }
        .store(in: &cancellables)

        Publishers.CombineLatest(
            $trainingTipsEnabled.eraseToAnyPublisher(),
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
        
        getShareablesUseCase
            .getShareablesPublisher(toolId: tool.id, toolLanguageId: toolPrimaryLanguage.dataModelId)
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

        self.trainingTipsEnabled = !trainingTipsEnabled
                        
        let step: FlowStep = trainingTipsEnabled ? .enableTrainingTipsTappedFromToolSettings : .disableTrainingTipsTappedFromToolSettings
        
        flowDelegate?.navigate(step: step)
    }
    
    func primaryLanguageTapped() {
        
        flowDelegate?.navigate(step: .primaryLanguageTappedFromToolSettings)
    }
    
    func parallelLanguageTapped() {
        
        flowDelegate?.navigate(step: .parallelLanguageTappedFromToolSettings)
    }
    
    func swapLanguageTapped() {

        let primaryLanguageId: String? = viewToolSettings?.primaryLanguage?.dataModelId
        let parallelLanguageId: String? = viewToolSettings?.parallelLanguage?.dataModelId
                
        guard let primaryLanguageId = primaryLanguageId, let parallelLanguageId = parallelLanguageId else {
            return
        }
        
        ToolSettingsViewModel.setToolSettingsPrimaryLanguageCancellable = setToolSettingsPrimaryLanguageUseCase
            .setLanguagePublisher(languageId: parallelLanguageId)
            .sink { _ in
                
            }
        
        ToolSettingsViewModel.setToolSettingsParallelLanguageCancellable = setToolSettingsParallelLanguageUseCase
            .setLanguagePublisher(languageId: primaryLanguageId)
            .sink { _ in
                
            }
    }
    
    func shareableTapped(shareable: ShareableDomainModel) {
        
        flowDelegate?.navigate(step: .shareableTappedFromToolSettings(shareable: shareable))
    }
}
