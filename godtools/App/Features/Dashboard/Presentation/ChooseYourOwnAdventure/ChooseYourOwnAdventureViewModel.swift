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

class ChooseYourOwnAdventureViewModel: MobileContentPagesViewModel {
                
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    let navBarAppearance: AppNavigationBarAppearance
    let languageFont: UIFont?
    
    @Published var hidesHomeButton: Bool = false
    @Published var hidesBackButton: Bool = true
        
    init(flowDelegate: FlowDelegate, renderer: MobileContentRenderer, initialPage: MobileContentPagesPage?, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getTranslatedLanguageName: GetTranslatedLanguageName, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase, selectedLanguageIndex: Int?) {
        
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
        
        super.init(renderer: renderer, initialPage: initialPage, resourcesRepository: resourcesRepository, translationsRepository: translationsRepository, mobileContentEventAnalytics: mobileContentEventAnalytics, getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, getTranslatedLanguageName: getTranslatedLanguageName, initialPageRenderingType: .chooseYourOwnAdventure, trainingTipsEnabled: trainingTipsEnabled, incrementUserCounterUseCase: incrementUserCounterUseCase, selectedLanguageIndex: selectedLanguageIndex)
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
    
    override func getPageNavigationEvent(page: Page, animated: Bool) -> MobileContentPagesNavigationEvent {
        
        let pages: [Page] = super.getPages()
        
        if pages.count == 1 && page.id == pages[0].id {
            
            return MobileContentPagesNavigationEvent(
                pageNavigation: PageNavigationCollectionViewNavigationModel(
                    navigationDirection: nil,
                    page: 0,
                    animated: false,
                    reloadCollectionViewDataNeeded: true,
                    insertPages: nil,
                    deletePages: nil
                ),
                setPages: nil,
                pagePositions: nil
            )
        }
        
        let navigationEvent: MobileContentPagesNavigationEvent
        
        if let backToPageIndex = pages.firstIndex(of: page) {
            
            // Backward Navigation
            
            let removeStartIndex: Int = backToPageIndex + 1
            let removedEndIndex: Int = pages.count - 1
            
            let pageIndexesToRemove: [Int]
            
            if removeStartIndex <= removedEndIndex {
                pageIndexesToRemove = Array(removeStartIndex...removedEndIndex)
            }
            else {
                pageIndexesToRemove = Array()
            }
            
            let pagesUpToBackToPage: [Page] = Array(pages[0...backToPageIndex])
            
            navigationEvent = MobileContentPagesNavigationEvent(
                pageNavigation: PageNavigationCollectionViewNavigationModel(
                    navigationDirection: nil,
                    page: backToPageIndex,
                    animated: true,
                    reloadCollectionViewDataNeeded: false,
                    insertPages: nil,
                    deletePages: pageIndexesToRemove
                ),
                setPages: pagesUpToBackToPage,
                pagePositions: nil
            )
        }
        else {
            
            // Forward Navigation
            
            let insertAtEndIndex: Int = pages.count
                        
            navigationEvent = MobileContentPagesNavigationEvent(
                pageNavigation: PageNavigationCollectionViewNavigationModel(
                    navigationDirection: nil,
                    page: insertAtEndIndex,
                    animated: true,
                    reloadCollectionViewDataNeeded: false,
                    insertPages: [insertAtEndIndex],
                    deletePages: nil
                ),
                setPages: pages + [page],
                pagePositions: nil
            )
        }
        
        return navigationEvent
    }
}

// MARK: - Inputs

extension ChooseYourOwnAdventureViewModel {
    
    @objc func homeTapped() {
        flowDelegate?.navigate(step: FlowStep.backTappedFromChooseYourOwnAdventure)
    }
    
    @objc func backTapped() {
        
        guard currentRenderedPageNumber > 0 else {
            return
        }
        
        if let parentPage = getCurrentPage()?.parentPage {
            
            super.navigateToPage(page: parentPage, animated: true)
        }
        else if let previousPage = super.getPage(index: currentRenderedPageNumber - 1) {
            
            super.navigateToPage(page: previousPage, animated: true)
        }
    }
    
    @objc func toolSettingsTapped() {
        
        let toolSettingsObserver = createToolSettingsObserver()
//        
//        trackActionAnalyticsUseCase
//            .trackAction(
//                screenName: analyticsScreenName,
//                actionName: "Tool Settings",
//                siteSection: analyticsSiteSection,
//                siteSubSection: "",
//                contentLanguage: nil,
//                contentLanguageSecondary: nil,
//                url: nil,
//                data: [ToolAnalyticsActionNames.shared.ACTION_SETTINGS: 1]
//            )
//        
        flowDelegate?.navigate(step: .toolSettingsTappedFromChooseYourOwnAdventure(toolSettingsObserver: toolSettingsObserver))
    }
    
    func languageTapped(index: Int) {
        
        let pageRenderer: MobileContentPageRenderer = renderer.value.pageRenderers[index]
        setPageRenderer(pageRenderer: pageRenderer, navigationEvent: nil, pagePositions: nil)
    }
}

extension ChooseYourOwnAdventureViewModel {
    
    private func createToolSettingsObserver() -> ToolSettingsObserver {
        
        let languages = ToolSettingsLanguages(
            primaryLanguageId: languages[0].id,
            parallelLanguageId: languages[safe: 1]?.id,
            selectedLanguageId: languages[selectedLanguageIndex].id
        )
        
        let toolSettingsObserver = ToolSettingsObserver(
            toolId: renderer.value.resource.id,
            languages: languages,
            pageNumber: currentRenderedPageNumber,
            trainingTipsEnabled: trainingTipsEnabled
        )
        
        toolSettingsObserver.$languages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (languages: ToolSettingsLanguages) in
                
                self?.setRendererPrimaryLanguage(
                    primaryLanguageId: languages.primaryLanguageId,
                    parallelLanguageId: languages.parallelLanguageId,
                    selectedLanguageId: languages.selectedLanguageId
                )
            }
            .store(in: &cancellables)
        
        toolSettingsObserver.$trainingTipsEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (trainingTipsEnabled: Bool) in
                
                self?.setTrainingTipsEnabled(enabled: trainingTipsEnabled)
            }
            .store(in: &cancellables)
        
//        self.toolSettingsObserver = toolSettingsObserver
        return toolSettingsObserver
    }
}
