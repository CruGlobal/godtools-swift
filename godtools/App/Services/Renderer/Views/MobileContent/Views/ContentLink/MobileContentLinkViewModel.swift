//
//  MobileContentLinkViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentLinkViewModel: MobileContentLinkViewModelType {
    
    private let linkModel: Link
    private let rendererPageModel: MobileContentRendererPageModel
    private let mobileContentAnalytics: MobileContentAnalytics
    private let fontService: FontService
    private let fontSize: CGFloat = 18
    private let fontWeight: UIFont.Weight = .regular
    
    let titleColor: UIColor
    
    required init(linkModel: Link, rendererPageModel: MobileContentRendererPageModel, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService) {
        
        self.linkModel = linkModel
        self.rendererPageModel = rendererPageModel
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
        self.titleColor = linkModel.textColor
    }
    
    var backgroundColor: UIColor {
        return .clear
    }
    
    var font: UIFont {
        return fontService.getFont(size: fontSize, weight: fontWeight)
    }
    
    var title: String? {
        return linkModel.text?.text
    }
    
    var linkEvents: [EventId] {
        return linkModel.events
    }
    
    var rendererState: State {
        return rendererPageModel.rendererState
    }
    
    func linkTapped() {
                        
        mobileContentAnalytics.trackEvents(events: linkModel.analyticsEvents, rendererPageModel: rendererPageModel)
    }
}
