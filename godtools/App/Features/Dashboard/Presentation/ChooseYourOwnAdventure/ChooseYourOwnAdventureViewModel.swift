//
//  ChooseYourOwnAdventureViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser
import Combine

class ChooseYourOwnAdventureViewModel: MobileContentRendererViewModel {
                
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    let navBarAppearance: AppNavigationBarAppearance
    let languageFont: UIFont?
    
    @Published var hidesHomeButton: Bool = false
    @Published var hidesBackButton: Bool = true
        
    init(flowDelegate: FlowDelegate, renderer: MobileContentRenderer, initialPage: MobileContentRendererInitialPage?, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getTranslatedLanguageName: GetTranslatedLanguageName, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase, selectedLanguageIndex: Int?) {
        
        self.flowDelegate = flowDelegate
                        
        let primaryManifest: Manifest = renderer.pageRenderers[0].manifest
                     
        navBarAppearance = AppNavigationBarAppearance(
            backgroundColor: primaryManifest.navBarColor,
            controlColor: primaryManifest.navBarControlColor,
            titleFont: FontLibrary.systemUIFont(size: 17, weight: .semibold),
            titleColor: primaryManifest.navBarControlColor,
            isTranslucent: false
        )
        
        languageFont = FontLibrary.systemUIFont(size: 14, weight: .regular)
        
        super.init(renderer: renderer, initialPage: initialPage, initialPageConfig: nil, resourcesRepository: resourcesRepository, translationsRepository: translationsRepository, mobileContentEventAnalytics: mobileContentEventAnalytics, getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, getTranslatedLanguageName: getTranslatedLanguageName, trainingTipsEnabled: trainingTipsEnabled, incrementUserCounterUseCase: incrementUserCounterUseCase, pagesNavigation: CYOAPagesNavigation(), selectedLanguageIndex: selectedLanguageIndex)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func pageDidAppear(page: Int) {
        super.pageDidAppear(page: page)
        
        let isFirstPage: Bool = page == 0
        
        if isFirstPage {
            hidesHomeButton = false
            hidesBackButton = true
        }
        else {
            hidesHomeButton = true
            hidesBackButton = false
        }
    }
    
    // MARK: - Page Navigation
    
    override func getInitialPages(pageRenderer: MobileContentPageRenderer) -> [Page] {
            
        if let firstVisiblePage = pageRenderer.getVisiblePageModels().first {
            return [firstVisiblePage]
        }
        
        return []
    }
    
    override func createToolSettingsObserver(with toolSettingsLanguages: ToolSettingsLanguages) -> CYOAToolSettingsObserver {
        let cyoaToolSettingsObserver = CYOAToolSettingsObserver(
            toolId: renderer.value.resource.id,
            languages: toolSettingsLanguages,
            pageNumber: currentPageNumber,
            trainingTipsEnabled: trainingTipsEnabled
        )
        
        return cyoaToolSettingsObserver
    }
}

// MARK: - Inputs

extension ChooseYourOwnAdventureViewModel {
    
    @objc func homeTapped() {
        flowDelegate?.navigate(step: FlowStep.backTappedFromChooseYourOwnAdventure)
    }
    
    @objc func backTapped() {
        
        guard currentPageNumber > 0 else {
            return
        }
        
        if let parentPage = getCurrentPage()?.parentPage {
            
            super.navigateToPage(page: parentPage, animated: true)
        }
        else if let previousPage = super.getPage(index: currentPageNumber - 1) {
            
            super.navigateToPage(page: previousPage, animated: true)
        }
    }
    
    @objc func toolSettingsTapped() {
        
        let toolSettingsObserver = setUpToolSettingsObserver()
        
        flowDelegate?.navigate(step: .toolSettingsTappedFromChooseYourOwnAdventure(toolSettingsObserver: toolSettingsObserver))
    }
    
    func languageTapped(index: Int) {
        
        let pageRenderer: MobileContentPageRenderer = renderer.value.pageRenderers[index]
        setPageRenderer(pageRenderer: pageRenderer, navigationEvent: nil, pagePositions: nil)
    }
}
