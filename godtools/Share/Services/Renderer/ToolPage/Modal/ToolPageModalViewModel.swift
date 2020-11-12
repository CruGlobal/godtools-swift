//
//  ToolPageContentFormViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageModalViewModelDelegate: class {
    
    func presentModal(modalViewModel: ToolPageModalViewModel)
    func dismissModal(modalViewModel: ToolPageModalViewModel)
}

class ToolPageModalViewModel: NSObject, ToolPageModalViewModelType {
    
    private let modalNode: ModalNode
    private let manifest: MobileContentXmlManifest
    private let translationsFileCache: TranslationsFileCache
    private let mobileContentAnalytics: MobileContentAnalytics
    private let mobileContentEvents: MobileContentEvents
    private let fontService: FontService
    private let toolPageColors: ToolPageColorsViewModel
    private let defaultTextNodeTextColor: UIColor?
    
    private weak var delegate: ToolPageModalViewModelDelegate?
    
    let contentViewModel: ToolPageContentStackViewModel
    
    required init(delegate: ToolPageModalViewModelDelegate, modalNode: ModalNode, manifest: MobileContentXmlManifest, language: LanguageModel, translationsFileCache: TranslationsFileCache, mobileContentAnalytics: MobileContentAnalytics, mobileContentEvents: MobileContentEvents, fontService: FontService, localizationServices: LocalizationServices, followUpsService: FollowUpsService, toolPageColors: ToolPageColorsViewModel, defaultTextNodeTextColor: UIColor?) {
        
        self.delegate = delegate
        self.modalNode = modalNode
        self.manifest = manifest
        self.translationsFileCache = translationsFileCache
        self.mobileContentAnalytics = mobileContentAnalytics
        self.mobileContentEvents = mobileContentEvents
        self.fontService = fontService
        self.toolPageColors = toolPageColors
        self.defaultTextNodeTextColor = defaultTextNodeTextColor
        
        contentViewModel = ToolPageContentStackViewModel(
            node: modalNode,
            manifest: manifest,
            language: language,
            translationsFileCache: translationsFileCache,
            mobileContentAnalytics: mobileContentAnalytics,
            mobileContentEvents: mobileContentEvents,
            fontService: fontService,
            localizationServices: localizationServices,
            followUpsService: followUpsService,
            itemSpacing: 15,
            scrollIsEnabled: true,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: nil,
            defaultButtonBorderColor: UIColor.white
        )
        
        super.init()
        
        addObservers()
    }
    
    deinit {
        
        removeObservers()
    }
    
    private func addObservers() {
        
        mobileContentEvents.eventButtonTappedSignal.addObserver(self) { [weak self] (buttonEvent: ButtonEvent) in
            guard let viewModel = self else {
                return
            }
            
            if viewModel.modalNode.listeners.contains(buttonEvent.event) {
                self?.delegate?.presentModal(modalViewModel: viewModel)
            }
            else if viewModel.modalNode.dismissListeners.contains(buttonEvent.event) {
                self?.delegate?.dismissModal(modalViewModel: viewModel)
            }
        }
    }
    
    private func removeObservers() {
        mobileContentEvents.eventButtonTappedSignal.removeObserver(self)
    }
    
    var backgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.9)
    }
}
