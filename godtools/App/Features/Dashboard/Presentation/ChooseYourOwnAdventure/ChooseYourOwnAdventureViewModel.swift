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
    
    let navBarAppearance: AppNavigationBarAppearance
    let languageFont: UIFont?
    let languageNames: [String]
    
    @Published var selectedLanguageIndex: Int = 0
        
    init(flowDelegate: FlowDelegate, renderer: MobileContentRenderer, initialPage: MobileContentPagesPage?, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking, fontService: FontService, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase) {
        
        self.flowDelegate = flowDelegate
        self.fontService = fontService
                
        let languages: [LanguageDomainModel] = renderer.pageRenderers.map({$0.language})
        languageNames = languages.map({$0.translatedName})
        
        let primaryManifest: Manifest = renderer.pageRenderers[0].manifest
                     
        navBarAppearance = AppNavigationBarAppearance(
            backgroundColor: primaryManifest.navBarColor,
            controlColor: primaryManifest.navBarControlColor,
            titleFont: fontService.getFont(size: 17, weight: .semibold),
            titleColor: primaryManifest.navBarControlColor,
            isTranslucent: false
        )
        
        languageFont = fontService.getFont(size: 14, weight: .regular)
        
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
    
    func languageTapped(index: Int) {
        
        let pageRenderer: MobileContentPageRenderer = renderer.value.pageRenderers[index]
        setPageRenderer(pageRenderer: pageRenderer, navigationEvent: nil, pagePositions: nil)
        
        selectedLanguageIndex = index
    }
}
