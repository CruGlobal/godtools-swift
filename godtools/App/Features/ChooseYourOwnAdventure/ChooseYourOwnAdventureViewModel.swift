//
//  ChooseYourOwnAdventureViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ChooseYourOwnAdventureViewModel: MobileContentPagesViewModel, ChooseYourOwnAdventureViewModelType {
    
    private static let navHomeImage: UIImage? = ImageCatalog.navHome.image
    
    private let localizationServices: LocalizationServices
    private let fontService: FontService
    
    let backButtonImage: ObservableValue<UIImage?>
    let navBarColors: ObservableValue<ChooseYourOwnAdventureNavBarModel>
    let navBarTitleType: ChooseYourOwnAdventureNavBarTitleType
    
    required init(flowDelegate: FlowDelegate, renderer: MobileContentRenderer, page: Int?, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking, localizationServices: LocalizationServices, fontService: FontService) {
        
        self.localizationServices = localizationServices
        self.fontService = fontService
        
        backButtonImage = ObservableValue(value: ChooseYourOwnAdventureViewModel.navHomeImage)
        
        let navBarColor: UIColor
        let navBarControlColor: UIColor

        let manifest: Manifest? = renderer.pageRenderers.first?.manifest
        
        if let manifest = manifest {
            navBarColor = manifest.navBarColor
            navBarControlColor = manifest.navBarControlColor
        }
        else {
            navBarColor = ColorPalette.gtBlue.color
            navBarControlColor = .white
        }
        
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
        
        super.init(flowDelegate: flowDelegate, renderer: renderer, page: page, mobileContentEventAnalytics: mobileContentEventAnalytics, initialPageRenderingType: .chooseYourOwnAdventure)
    }

    required init(flowDelegate: FlowDelegate, renderer: MobileContentRenderer, page: Int?, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking, initialPageRenderingType: MobileContentPagesInitialPageRenderingType) {
        fatalError("init(flowDelegate:renderer:page:mobileContentEventAnalytics:initialPageRenderingType:) has not been implemented")
    }
    
    override func pageDidAppear(page: Int) {
        super.pageDidAppear(page: page)
        
        let isFirstPage: Bool = page == 0
        let navBackImage: UIImage?
        
        if isFirstPage {
            navBackImage = ChooseYourOwnAdventureViewModel.navHomeImage
        }
        else {
            navBackImage = ImageCatalog.navBack.image
        }
        
        backButtonImage.accept(value: navBackImage)
    }
    
    func getNavBarLanguageTitles() -> [String] {
        
        let languageTitles: [String] = renderer.pageRenderers.map({ LanguageViewModel(language: $0.language, localizationServices: localizationServices).translatedLanguageName })
        guard languageTitles.count > 1 else {
            return Array()
        }
        return languageTitles
    }
    
    func navBackTapped() {
        
        let isFirstPage: Bool = currentPage == 0
        
        if isFirstPage {
            flowDelegate?.navigate(step: FlowStep.backTappedFromChooseYourOwnAdventure)
        }
    }
    
    func navLanguageTapped(index: Int) {
        
        let pageRenderer: MobileContentPageRenderer = renderer.pageRenderers[index]
        setPageRenderer(pageRenderer: pageRenderer)
    }
}
