//
//  ChooseYourOwnAdventureViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ChooseYourOwnAdventureViewModel: MobileContentPagesViewModel {
    
    private static let navHomeImage: UIImage? = ImageCatalog.navHome.uiImage
    
    private let fontService: FontService
    
    private weak var flowDelegate: FlowDelegate?
    
    let backButtonImage: ObservableValue<UIImage?>
    let navBarColors: ObservableValue<ChooseYourOwnAdventureNavBarModel>
    let navBarTitleType: ChooseYourOwnAdventureNavBarTitleType
    
    init(flowDelegate: FlowDelegate, renderer: MobileContentRenderer, page: Int?, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking, fontService: FontService, trainingTipsEnabled: Bool) {
        
        self.flowDelegate = flowDelegate
        self.fontService = fontService
        
        backButtonImage = ObservableValue(value: ChooseYourOwnAdventureViewModel.navHomeImage)
        
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
        
        super.init(renderer: renderer, page: page, resourcesRepository: resourcesRepository, translationsRepository: translationsRepository, mobileContentEventAnalytics: mobileContentEventAnalytics, initialPageRenderingType: .chooseYourOwnAdventure, trainingTipsEnabled: trainingTipsEnabled)
    }
    
    override func pageDidAppear(page: Int) {
        super.pageDidAppear(page: page)
        
        let isFirstPage: Bool = page == 0
        let navBackImage: UIImage?
        
        if isFirstPage {
            navBackImage = ChooseYourOwnAdventureViewModel.navHomeImage
        }
        else {
            navBackImage = ImageCatalog.navBack.uiImage
        }
        
        backButtonImage.accept(value: navBackImage)
    }
    
    func getNavBarLanguageTitles() -> [String] {
        
        let languageTitles: [String] = renderer.value.pageRenderers.map({$0.language.translatedName})
        guard languageTitles.count > 1 else {
            return Array()
        }
        return languageTitles
    }
}

// MARK: - Inpits

extension ChooseYourOwnAdventureViewModel {
    
    func navBackTapped() {
        
        let isFirstPage: Bool = currentPage == 0
        
        if isFirstPage {
            flowDelegate?.navigate(step: FlowStep.backTappedFromChooseYourOwnAdventure)
        }
    }
    
    func navLanguageTapped(index: Int) {
        
        let pageRenderer: MobileContentPageRenderer = renderer.value.pageRenderers[index]
        setPageRenderer(pageRenderer: pageRenderer)
    }
}
