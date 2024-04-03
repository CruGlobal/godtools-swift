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
        
    init(flowDelegate: FlowDelegate, renderer: MobileContentRenderer, initialPage: MobileContentPagesPage?, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, translatedLanguageNameRepository: TranslatedLanguageNameRepository, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase, selectedLanguageIndex: Int?) {
        
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
        
        super.init(renderer: renderer, initialPage: initialPage, resourcesRepository: resourcesRepository, translationsRepository: translationsRepository, mobileContentEventAnalytics: mobileContentEventAnalytics, getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, translatedLanguageNameRepository: translatedLanguageNameRepository, initialPageRenderingType: .chooseYourOwnAdventure, trainingTipsEnabled: trainingTipsEnabled, incrementUserCounterUseCase: incrementUserCounterUseCase, selectedLanguageIndex: selectedLanguageIndex)
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
            
        let allPages: [Page] = pageRenderer.getAllPageModels()
        
        if let introPage = allPages.first(where: {$0.id.contains("intro")}) {
            return [introPage]
        }
        else if let firstPage = allPages.first {
            return [firstPage]
        }
        
        return []
    }
    
    override func getPageNavigationEvent(page: Page, animated: Bool, reloadCollectionViewDataNeeded: Bool) -> MobileContentPagesNavigationEvent {
        
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
            
            let pageIndexesToRemove: [Int] = Array((backToPageIndex + 1)...(pages.count - 1))
            
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
    
    func languageTapped(index: Int) {
        
        let pageRenderer: MobileContentPageRenderer = renderer.value.pageRenderers[index]
        setPageRenderer(pageRenderer: pageRenderer, navigationEvent: nil, pagePositions: nil)
    }
}
