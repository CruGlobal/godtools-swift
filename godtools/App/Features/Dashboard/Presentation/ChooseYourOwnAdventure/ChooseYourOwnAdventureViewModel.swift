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
        
    private let fontService: FontService
    private let initialSelectedLanguageIndex: Int?
    
    @Published private var languages: [LanguageDomainModel] = Array()
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var didSetInitialSelectedLanguageIndex: Bool = false
    
    private weak var flowDelegate: FlowDelegate?
    
    let navBarAppearance: AppNavigationBarAppearance
    let languageFont: UIFont?
    
    @Published var hidesHomeButton: Bool = false
    @Published var hidesBackButton: Bool = true
    @Published var languageNames: [String] = Array()
    @Published var selectedLanguageIndex: Int = 0
        
    init(flowDelegate: FlowDelegate, renderer: MobileContentRenderer, initialPage: MobileContentPagesPage?, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking, fontService: FontService, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase, selectedLanguageIndex: Int?) {
        
        self.flowDelegate = flowDelegate
        self.fontService = fontService
        self.initialSelectedLanguageIndex = selectedLanguageIndex
                        
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
        
        $languages.eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (languages: [LanguageDomainModel]) in
                self?.languageNames = languages.map({$0.translatedName})
                self?.setInitialSelectedLanguageIndexIfNeeded(languages: languages)
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func setInitialSelectedLanguageIndexIfNeeded(languages: [LanguageDomainModel]) {
        
        guard !didSetInitialSelectedLanguageIndex && !languages.isEmpty else {
            return
        }
        
        didSetInitialSelectedLanguageIndex = true
        
        guard let initialSelectedLanguageIndex = self.initialSelectedLanguageIndex, initialSelectedLanguageIndex >= 0 && initialSelectedLanguageIndex < languages.count else {
            return
        }
        
        languageTapped(index: initialSelectedLanguageIndex)
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
    
    override func setRenderer(renderer: MobileContentRenderer, pageRendererIndex: Int?, navigationEvent: MobileContentPagesNavigationEvent?) {
                
        languages = renderer.pageRenderers.map({$0.language})
        
        super.setRenderer(renderer: renderer, pageRendererIndex: selectedLanguageIndex, navigationEvent: navigationEvent)
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
