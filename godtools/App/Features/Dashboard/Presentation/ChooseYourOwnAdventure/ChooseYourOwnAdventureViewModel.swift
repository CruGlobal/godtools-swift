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
        
    private let hidesHomeButtonSubject: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false) // TODO: Can be removed and instead use @Published property once using SwiftUI. ~Levi
    private let hidesBackButtonSubject: CurrentValueSubject<Bool, Never> = CurrentValueSubject(true) // TODO: Can be removed and instead use @Published property once using SwiftUI. ~Levi
    private let fontService: FontService
    
    private weak var flowDelegate: FlowDelegate?
    
    let navBarColors: ObservableValue<ChooseYourOwnAdventureNavBarModel>
    let navBarTitleType: ChooseYourOwnAdventureNavBarTitleType
    
    init(flowDelegate: FlowDelegate, renderer: MobileContentRenderer, initialPage: MobileContentPagesPage?, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking, fontService: FontService, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase) {
        
        self.flowDelegate = flowDelegate
        self.fontService = fontService
                
        let navBarColor: UIColor
        let navBarControlColor: UIColor

        let primaryManifest: Manifest = renderer.pageRenderers[0].manifest
        
        navBarColor = primaryManifest.navBarColor
        navBarControlColor = primaryManifest.navBarControlColor
        
        let navBarModel = ChooseYourOwnAdventureNavBarModel(
            barColor: navBarColor,
            controlColor: navBarControlColor,
            titleFont: fontService.getFont(size: 17, weight: .semibold),
            languageToggleBorderColor: navBarControlColor,
            languageToggleSelectedColor: navBarControlColor,
            languageToggleDeselectedColor: navBarColor
        )
        
        navBarColors = ObservableValue(value: navBarModel)
        
        if renderer.pageRenderers.count > 1 {
            navBarTitleType = .languageToggle
        }
        else {
            navBarTitleType = .title(title: "GodTools")
        }
        
        super.init(renderer: renderer, initialPage: initialPage, resourcesRepository: resourcesRepository, translationsRepository: translationsRepository, mobileContentEventAnalytics: mobileContentEventAnalytics, initialPageRenderingType: .chooseYourOwnAdventure, trainingTipsEnabled: trainingTipsEnabled, incrementUserCounterUseCase: incrementUserCounterUseCase)
    }
    
    // TODO: Can be removed and instead use @Published property once using SwiftUI. ~Levi
    var hidesHomeButton: AnyPublisher<Bool, Never> {
        return hidesHomeButtonSubject.eraseToAnyPublisher()
    }
    
    // TODO: Can be removed and instead use @Published property once using SwiftUI. ~Levi
    var hidesBackButton: AnyPublisher<Bool, Never> {
        return hidesBackButtonSubject.eraseToAnyPublisher()
    }
    
    override func pageDidAppear(page: Int) {
        super.pageDidAppear(page: page)
        
        let isFirstPage: Bool = page == 0
        
        if isFirstPage {
            hidesHomeButtonSubject.send(false)
            hidesBackButtonSubject.send(true)
        }
        else {
            hidesHomeButtonSubject.send(true)
            hidesBackButtonSubject.send(false)
        }
    }
    
    func getNavBarLanguageTitles() -> [String] {
        
        let languageTitles: [String] = renderer.value.pageRenderers.map({$0.language.translatedName})
        guard languageTitles.count > 1 else {
            return Array()
        }
        return languageTitles
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
        
        let event = MobileContentPagesNavigationEvent(
            pageNavigation: PageNavigationCollectionViewNavigationModel(
                navigationDirection: nil,
                page: currentRenderedPageNumber - 1,
                animated: true,
                reloadCollectionViewDataNeeded: false,
                insertPages: nil
            ),
            pagePositions: nil
        )
        
        pageNavigationEventSignal.accept(value: event)
    }
    
    func navLanguageTapped(index: Int) {
        
        let pageRenderer: MobileContentPageRenderer = renderer.value.pageRenderers[index]
        setPageRenderer(pageRenderer: pageRenderer, navigationEvent: nil, pagePositions: nil)
    }
}
