//
//  MobileContentLinkViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentLinkViewModel: MobileContentViewModel, ClickableMobileContentViewModel {
    
    private let linkModel: Link
    private let renderedPageContext: MobileContentRenderedPageContext
    private let mobileContentAnalytics: MobileContentAnalytics
    private let fontService: FontService
    private let fontSize: CGFloat = 18
    private let fontWeight: UIFont.Weight = .regular
    
    let titleColor: UIColor
    
    init(linkModel: Link, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService) {
        
        self.linkModel = linkModel
        self.renderedPageContext = renderedPageContext
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
        self.titleColor = linkModel.text.textColor
        
        super.init(baseModel: linkModel)
    }
    
    var backgroundColor: UIColor {
        return .clear
    }
    
    var font: UIFont {
        return fontService.getFont(size: fontSize, weight: fontWeight)
    }
    
    var title: String? {
        return linkModel.text.text
    }
    
    var linkEvents: [EventId] {
        return linkModel.events
    }
    
    var rendererState: State {
        return renderedPageContext.rendererState
    }
    
    func getClickableUrl() -> URL? {
        return getClickableUrl(model: linkModel)
    }
}

// MARK: - Inpits

extension MobileContentLinkViewModel {
    
    func linkTapped() {
        trackClickableEvents(model: linkModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
}
