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
    
    private let localizationServices: LocalizationServices
    private let currentPageRenderer: CurrentValueSubject<MobileContentPageRenderer, Never>
    private let primaryLanguageSubject: CurrentValueSubject<LanguageModel, Never>
    private let parallelLanguageSubject: CurrentValueSubject<LanguageModel?, Never>
    private let trainingTipsEnabledSubject: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    
    private var trainingTipsCancellable: AnyCancellable?
    private var currentPageRendererCancellable: AnyCancellable?
    private var primaryLanguageCancellable: AnyCancellable?
    private var parallelLanguageCancellable: AnyCancellable?
    
    private weak var flowDelegate: FlowDelegate?
    
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
        
    required init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, currentPageRenderer: CurrentValueSubject<MobileContentPageRenderer, Never>, primaryLanguageSubject: CurrentValueSubject<LanguageModel, Never>, parallelLanguageSubject: CurrentValueSubject<LanguageModel?, Never>, trainingTipsEnabled: Bool) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        self.currentPageRenderer = currentPageRenderer
        self.primaryLanguageSubject = primaryLanguageSubject
        self.parallelLanguageSubject = parallelLanguageSubject
        
        title = localizationServices.stringForMainBundle(key: "toolSettings.title")
        shareLinkTitle = localizationServices.stringForMainBundle(key: "toolSettings.option.shareLink.title")
        screenShareTitle = localizationServices.stringForMainBundle(key: "toolSettings.option.screenShare.title")
        
        trainingTipsEnabledSubject.send(trainingTipsEnabled)
        
        trainingTipsCancellable = trainingTipsEnabledSubject.sink { [weak self] (trainingTipsEnabled: Bool) in
            self?.trainingTipsTitle = trainingTipsEnabled ? localizationServices.stringForMainBundle(key: "toolSettings.option.trainingTips.hide.title") : localizationServices.stringForMainBundle(key: "toolSettings.option.trainingTips.show.title")
            self?.trainingTipsIcon = trainingTipsEnabled ? Image(ImageCatalog.toolSettingsOptionHideTips.name) : Image(ImageCatalog.toolSettingsOptionTrainingTips.name)
        }
        chooseLanguageTitle = localizationServices.stringForMainBundle(key: "toolSettings.chooseLanguage.title")
        chooseLanguageToggleMessage = localizationServices.stringForMainBundle(key: "toolSettings.chooseLanguage.toggleMessage")
        shareablesTitle = localizationServices.stringForMainBundle(key: "toolSettings.shareables.title")
        
        currentPageRendererCancellable = currentPageRenderer.sink(receiveValue: { [weak self] (pageRenderer: MobileContentPageRenderer) in

            self?.pageRendererChanged(pageRenderer: pageRenderer)
        })
        
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
        
        pageRendererChanged(pageRenderer: currentPageRenderer.value)
    }
    
    private func getTranslatedLanguageName(language: LanguageModel) -> String {
        return LanguageViewModel(language: language, localizationServices: localizationServices).translatedLanguageName
    }
    
    private func pageRendererChanged(pageRenderer: MobileContentPageRenderer) {
        
        hidesToggleTrainingTipsButton = pageRenderer.manifest.tips.isEmpty
        hidesShareables = pageRenderer.manifest.shareables.isEmpty
        numberOfShareableItems = pageRenderer.manifest.shareables.count
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

        trainingTipsEnabledSubject.send(!trainingTipsEnabledSubject.value)
                
        let step: FlowStep = trainingTipsEnabledSubject.value ? .enableTrainingTipsTappedFromToolSettings : .disableTrainingTipsTappedFromToolSettings
        
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
    
    func getShareableItemViewModel(index: Int) -> ToolSettingsShareableItemViewModel {
        
        return ToolSettingsShareableItemViewModel(
            shareable: currentPageRenderer.value.manifest.shareables[index],
            manifestResourcesCache: currentPageRenderer.value.manifestResourcesCache
        )
    }
    
    func shareableTapped(index: Int) {
        
        let manifestResourcesCache: ManifestResourcesCache = currentPageRenderer.value.manifestResourcesCache
        let shareable: Shareable = currentPageRenderer.value.manifest.shareables[index]
        
        guard let shareableImage = shareable as? ShareableImage, let resource = shareableImage.resource, let imageToShare = manifestResourcesCache.getImageFromManifestResources(resource: resource) else {
            return
        }
        
        flowDelegate?.navigate(step: .shareableTappedFromToolSettings(shareImage: imageToShare))
    }
}
