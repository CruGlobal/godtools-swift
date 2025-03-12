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
        
        super.init(renderer: renderer, initialPage: initialPage, initialPageConfig: nil, resourcesRepository: resourcesRepository, translationsRepository: translationsRepository, mobileContentEventAnalytics: mobileContentEventAnalytics, getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, getTranslatedLanguageName: getTranslatedLanguageName, trainingTipsEnabled: trainingTipsEnabled, incrementUserCounterUseCase: incrementUserCounterUseCase, selectedLanguageIndex: selectedLanguageIndex)
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
    
    override func getPageNavigationEvent(page: Page, animated: Bool, reloadCollectionViewDataNeeded: Bool, parentPageParams: MobileContentParentPageParams?, isBackNavigation: Bool) -> MobileContentPagesNavigationEvent {
        
        let pages: [Page] = super.getPages()
        
        let pageNavigation: PageNavigationCollectionViewNavigationModel
        let setPages: [Page]?
        
        if pages.count == 1 && page.id == pages[0].id {
            
            pageNavigation = PageNavigationCollectionViewNavigationModel(
                navigationDirection: nil,
                page: 0,
                animated: false,
                reloadCollectionViewDataNeeded: true,
                insertPages: nil,
                deletePages: nil,
                reloadPages: nil
            )
            
            setPages = nil
        }
        else if let backToPageIndex = pages.firstIndex(of: page) {
                        
            // Backward Navigation - Page is in navigation stack
            
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
            
            pageNavigation = PageNavigationCollectionViewNavigationModel(
                navigationDirection: nil,
                page: backToPageIndex,
                animated: true,
                reloadCollectionViewDataNeeded: false,
                insertPages: nil,
                deletePages: pageIndexesToRemove,
                reloadPages: nil
            )
            
            setPages = pagesUpToBackToPage
        }
        else if isBackNavigation, let nearestAncestorPageIndex = super.getNearestAncestorPageIndex(page: page) {
                        
            // Backward Navigation - Page is NOT in navigation stack, but an ancestor page is in stack.  Add to top of ancestor page.
            
            let insertPageAtIndex: Int = nearestAncestorPageIndex + 1
            
            let removeStartIndex: Int = insertPageAtIndex + 1
            let removedEndIndex: Int = pages.count - 1
            
            let pageIndexesToRemove: [Int]
            
            if removeStartIndex <= removedEndIndex {
                pageIndexesToRemove = Array(removeStartIndex...removedEndIndex)
            }
            else {
                pageIndexesToRemove = Array()
            }
                        
            pageNavigation = PageNavigationCollectionViewNavigationModel(
                navigationDirection: nil,
                page: insertPageAtIndex,
                animated: true,
                reloadCollectionViewDataNeeded: false,
                insertPages: nil,
                deletePages: pageIndexesToRemove,
                reloadPages: [insertPageAtIndex]
            )
            
            setPages = Array(pages[0...nearestAncestorPageIndex]) + [page]
        }
        else {
            
            // Forward Navigation
            
            let insertAtEndIndex: Int = pages.count
                   
            pageNavigation = PageNavigationCollectionViewNavigationModel(
                navigationDirection: nil,
                page: insertAtEndIndex,
                animated: true,
                reloadCollectionViewDataNeeded: false,
                insertPages: [insertAtEndIndex],
                deletePages: nil,
                reloadPages: nil
            )
            
            setPages = pages + [page]
        }
        
        let navigationEvent = MobileContentPagesNavigationEvent(
            pageNavigation: pageNavigation,
            setPages: setPages,
            pagePositions: nil,
            parentPageParams: parentPageParams
        )
        
        return navigationEvent
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
        
        super.navigateToParentPage()
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
