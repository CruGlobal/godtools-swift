//
//  TractPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class TractPageViewModel: MobileContentPageViewModel {
    
    private let pageModel: TractPage
    
    private var cardPosition: Int?
    
    let hidesCallToAction: Bool
    
    init(pageModel: TractPage, renderedPageContext: MobileContentRenderedPageContext, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, mobileContentAnalytics: MobileContentRendererAnalytics) {
                
        self.pageModel = pageModel
        self.hidesCallToAction = pageModel.isLastPage
                
        super.init(pageModel: pageModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics, trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase, hidesBackgroundImage: false)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override var analyticsScreenName: String {
        
        let resource: ResourceDataModel = renderedPageContext.resource
        let page: Int32 = renderedPageContext.pageModel.position
        
        let cardAnalyticsScreenName: String
        
        if let cardPosition = self.cardPosition {
            cardAnalyticsScreenName = TractPageCardAnalyticsScreenName(cardPosition: cardPosition).screenName
        }
        else {
            cardAnalyticsScreenName = ""
        }
                        
        return resource.abbreviation + "-" + String(page) + cardAnalyticsScreenName
    }
    
    var numberOfVisibleCards: Int {
        return pageModel.visibleCards.count
    }
    
    var bottomViewColor: UIColor {
        
        let manifest: Manifest = renderedPageContext.manifest
        let color: UIColor = manifest.navBarColor.toUIColor()
        
        return color.withAlphaComponent(0.1)
    }
    
    var page: Int {
        return renderedPageContext.page
    }
    
    override func pageDidAppear() {
                
        super.pageDidAppear()
    }
}

// MARK: - Inputs

extension TractPageViewModel {
    
    func callToActionWillAppear() -> TractPageCallToActionView? {

        guard !hidesCallToAction else {
            return nil
        }
        
        for viewFactory in renderedPageContext.viewRenderer.pageViewFactories.factories {
            if let tractPageViewFactory = viewFactory as? TractPageViewFactory {
                return tractPageViewFactory.getCallToActionView(callToActionModel: nil, renderedPageContext: renderedPageContext)
            }
        }
        
        return nil
    }
    
    func didChangeCardPosition(cardPosition: Int?) {
        self.cardPosition = cardPosition
    }
}
