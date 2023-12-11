//
//  ToolSettingsViewModel.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/11/22.
//

import Foundation
import SwiftUI
import GodToolsToolParser
import Combine

class ToolSettingsViewModel: ObservableObject {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewToolSettingsUseCase: ViewToolSettingsUseCase
    private let localizationServices: LocalizationServices
    private let getShareableImageUseCase: GetShareableImageUseCase
    private let currentPageRenderer: CurrentValueSubject<MobileContentPageRenderer, Never>
    private let primaryLanguageSubject: CurrentValueSubject<LanguageDomainModel, Never>
    private let parallelLanguageSubject: CurrentValueSubject<LanguageDomainModel?, Never>
    
    private var currentPageRendererCancellable: AnyCancellable?
    private var primaryLanguageCancellable: AnyCancellable?
    private var parallelLanguageCancellable: AnyCancellable?
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var interfaceStrings: ToolSettingsInterfaceStringsDomainModel?
    @Published private var trainingTipsEnabled: Bool = false
    
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
    @Published var hidesShareables: Bool = false
    @Published var shareablesTitle: String = ""
    @Published var numberOfShareableItems: Int = 0
        
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewToolSettingsUseCase: ViewToolSettingsUseCase, localizationServices: LocalizationServices, getShareableImageUseCase: GetShareableImageUseCase, currentPageRenderer: CurrentValueSubject<MobileContentPageRenderer, Never>, primaryLanguageSubject: CurrentValueSubject<LanguageDomainModel, Never>, parallelLanguageSubject: CurrentValueSubject<LanguageDomainModel?, Never>, trainingTipsEnabled: Bool) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewToolSettingsUseCase = viewToolSettingsUseCase
        self.localizationServices = localizationServices
        self.getShareableImageUseCase = getShareableImageUseCase
        self.currentPageRenderer = currentPageRenderer
        self.primaryLanguageSubject = primaryLanguageSubject
        self.parallelLanguageSubject = parallelLanguageSubject
        self.trainingTipsEnabled = trainingTipsEnabled
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewToolSettingsDomainModel, Never> in
                
                return self.viewToolSettingsUseCase
                    .viewPublisher(appLanguage: appLanguage)
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
                
                self?.interfaceStrings = domainModel.interfaceStrings
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
        
        currentPageRendererCancellable = currentPageRenderer.sink(receiveValue: { [weak self] (pageRenderer: MobileContentPageRenderer) in

            self?.pageRendererChanged(pageRenderer: pageRenderer)
        })
        
        primaryLanguageCancellable = primaryLanguageSubject.sink(receiveValue: { [weak self] (language: LanguageDomainModel) in
           
            self?.primaryLanguageTitle = language.translatedName
        })
        
        parallelLanguageCancellable = parallelLanguageSubject.sink(receiveValue: { [weak self] (language: LanguageDomainModel?) in
            
            if let language = language {
                self?.parallelLanguageTitle = language.translatedName
            }
            else {
                self?.parallelLanguageTitle = localizationServices.stringForSystemElseEnglish(key: "toolSettings.chooseLanguage.noParallelLanguageTitle")
            }
        })
        
        pageRendererChanged(pageRenderer: currentPageRenderer.value)
    }
    
    private func pageRendererChanged(pageRenderer: MobileContentPageRenderer) {
        
        hidesToggleTrainingTipsButton = !pageRenderer.manifest.hasTips
        hidesShareables = pageRenderer.manifest.shareables.isEmpty
        numberOfShareableItems = pageRenderer.manifest.shareables.count
    }
    
    func getShareableItemViewModel(index: Int) -> ToolSettingsShareableItemViewModel {
        
        return ToolSettingsShareableItemViewModel(
            shareable: currentPageRenderer.value.manifest.shareables[index],
            manifestResourcesCache: currentPageRenderer.value.manifestResourcesCache
        )
    }
}

// MARK: - Inputs

extension ToolSettingsViewModel {
    
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
        
        flowDelegate?.navigate(step: .swapLanguagesTappedFromToolSettings)
    }
    
    func shareableTapped(index: Int) {
        
        let manifestResourcesCache: MobileContentRendererManifestResourcesCache = currentPageRenderer.value.manifestResourcesCache
        let shareable: Shareable = currentPageRenderer.value.manifest.shareables[index]
        
        guard let shareableImageDomainModel = getShareableImageUseCase.getShareableImage(from: shareable, manifestResourcesCache: manifestResourcesCache) else {
            return
        }
        
        flowDelegate?.navigate(step: .shareableTappedFromToolSettings(shareableImageDomainModel: shareableImageDomainModel))
    }
}
