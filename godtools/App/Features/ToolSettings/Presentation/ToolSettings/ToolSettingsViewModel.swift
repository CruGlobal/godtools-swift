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

@MainActor
final class ToolSettingsViewModel: ObservableObject {
        
    private let stepEmitter: FlowStepEmitter
    private let toolSettingsObserver: ToolSettingsObserver
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getToolSettingsStringsUseCase: GetToolSettingsStringsUseCase
    private let getToolSettingsUseCase: GetToolSettingsUseCase
    private let getShareablesUseCase: GetShareablesUseCase
    private let getShareableImageUseCase: GetShareableImageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    @Published private var appLanguage = AppLanguageDomainModel.english
    
    @Published private(set) var strings = ToolSettingsStringsDomainModel.emptyValue
    @Published private(set) var toolOptions: [ToolSettingsOption] = Array()
    @Published private(set) var trainingTipsIcon: SwiftUI.Image = Image("")
    @Published private(set) var trainingTipsTitle: String = ""
    @Published private(set) var primaryLanguageTitle: String = ""
    @Published private(set) var parallelLanguageTitle: String = ""
    @Published private(set) var shareables: [ShareableDomainModel] = Array()
        
    init(
        stepEmitter: FlowStepEmitter,
        toolSettingsObserver: ToolSettingsObserver,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getToolSettingsStringsUseCase: GetToolSettingsStringsUseCase,
        getToolSettingsUseCase: GetToolSettingsUseCase,
        getShareablesUseCase: GetShareablesUseCase,
        getShareableImageUseCase: GetShareableImageUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.toolSettingsObserver = toolSettingsObserver
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getToolSettingsStringsUseCase = getToolSettingsStringsUseCase
        self.getToolSettingsUseCase = getToolSettingsUseCase
        self.getShareablesUseCase = getShareablesUseCase
        self.getShareableImageUseCase = getShareableImageUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (appLanguage: AppLanguageDomainModel) in

                self?.appLanguage = appLanguage
                self?.didSetAppLanguage(appLanguage: appLanguage)
            })
            .store(in: &cancellables)

        Publishers.CombineLatest3(
            $appLanguage.dropFirst(),
            toolSettingsObserver.$languages,
            $strings.dropFirst()
        )
        .map { (appLanguage: AppLanguageDomainModel, languages: ToolSettingsLanguages, strings: ToolSettingsStringsDomainModel) in
            
            Publishers.CombineLatest(
                getToolSettingsUseCase
                    .execute(
                        appLanguage: appLanguage,
                        toolId: toolSettingsObserver.toolId,
                        toolLanguageId: languages.selectedLanguageId,
                        toolPrimaryLanguageId: languages.primaryLanguageId,
                        toolParallelLanguageId: languages.parallelLanguageId
                    )
                ,
                Just(strings)
                    .setFailureType(to: Error.self)
            )
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in
            
        }, receiveValue: { [weak self] (toolSettings: ToolSettingsDomainModel, strings: ToolSettingsStringsDomainModel) in
            
            self?.toolOptions = Self.getAvailableToolOptions(
                domainModel: toolSettings,
                toolSettingsObserver: toolSettingsObserver
            )
            
            self?.primaryLanguageTitle = toolSettings.primaryLanguage?.languageName ?? ""
            self?.parallelLanguageTitle = toolSettings.parallelLanguage?.languageName ?? strings.chooseParallelLanguageActionTitle
        })
        .store(in: &cancellables)

        Publishers.CombineLatest(
            toolSettingsObserver.$trainingTipsEnabled,
            $strings
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (trainingTipsEnabled: Bool, strings: ToolSettingsStringsDomainModel?) in
            
            guard let strings = strings else {
                return
            }
            
            self?.trainingTipsTitle = trainingTipsEnabled ? strings.toolOptionDisableTrainingTips : strings.toolOptionEnableTrainingTips
            self?.trainingTipsIcon = trainingTipsEnabled ? ImageCatalog.toolSettingsOptionHideTips.image : ImageCatalog.toolSettingsOptionTrainingTips.image
        }
        .store(in: &cancellables)
        
        toolSettingsObserver.$languages
            .map { (languages: ToolSettingsLanguages) in

                AnyPublisher() {
                    try await getShareablesUseCase
                        .execute(
                            toolId: toolSettingsObserver.toolId,
                            toolLanguageId: languages.selectedLanguageId
                        )
                }
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (shareables: [ShareableDomainModel]) in
                
                self?.shareables = shareables
            })
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }

    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {

        strings = getToolSettingsStringsUseCase
            .execute(appLanguage: appLanguage)
    }

    private static func getAvailableToolOptions(domainModel: ToolSettingsDomainModel, toolSettingsObserver: ToolSettingsObserver) -> [ToolSettingsOption] {
        
        var toolOptions: [ToolSettingsOption] = Array()
        
        if toolSettingsObserver.isLinkShareable {
            toolOptions.append(.shareLink)
        }
        
        if toolSettingsObserver.isRemoteShareable {
            toolOptions.append(.shareScreen)
        }
        
        if domainModel.hasTips {
            toolOptions.append(.trainingTips)
        }
                
        return toolOptions
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
        stepEmitter.emit(step: AppFlowStep.closeTappedFromToolSettings)
    }
    
    func shareLinkTapped() {
        
        stepEmitter.emit(step: AppFlowStep.shareLinkTappedFromToolSettings)
    }
    
    func screenShareTapped() {
        
        stepEmitter.emit(step: AppFlowStep.screenShareTappedFromToolSettings)
    }
    
    func trainingTipsTapped() {

        let trainingTipsEnabled: Bool = !toolSettingsObserver.trainingTipsEnabled
               
        toolSettingsObserver.trainingTipsEnabled = trainingTipsEnabled
    }
    
    func primaryLanguageTapped() {
        
        stepEmitter.emit(step: AppFlowStep.primaryLanguageTappedFromToolSettings)
    }
    
    func parallelLanguageTapped() {
        
        stepEmitter.emit(step: AppFlowStep.parallelLanguageTappedFromToolSettings)
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
        
        stepEmitter.emit(step: AppFlowStep.shareableTappedFromToolSettings(shareable: shareable))
    }
}
