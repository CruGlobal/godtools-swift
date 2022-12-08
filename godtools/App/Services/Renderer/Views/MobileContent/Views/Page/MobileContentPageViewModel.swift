//
//  MobileContentPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser
import SwiftUI

class MobileContentPageViewModel: MobileContentViewModel {
    
    private let pageModel: Page
    private let renderedPageContext: MobileContentRenderedPageContext
    private let hidesBackgroundImage: Bool
        
    init(pageModel: Page, renderedPageContext: MobileContentRenderedPageContext, hidesBackgroundImage: Bool) {
        
        self.pageModel = pageModel
        self.renderedPageContext = renderedPageContext
        self.hidesBackgroundImage = hidesBackgroundImage
        
        super.init(baseModel: pageModel)
    }
    
    var analyticsScreenName: String {
        
        let resource: ResourceModel = renderedPageContext.resource
        let page: Int = renderedPageContext.page
        
        return resource.abbreviation + "-" + String(page)
    }
    
    var analyticsSiteSection: String {
        
        let resource: ResourceModel = renderedPageContext.resource
 
        return resource.abbreviation
    }
    
    var analyticsSiteSubSection: String {
        return ""
    }
    
    var backgroundColor: UIColor {
        return pageModel.backgroundColor
    }
}

// MARK: - Inputs

extension MobileContentPageViewModel {
    
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel? {
               
        guard !hidesBackgroundImage else {
            return nil
        }
        
        let manifest: Manifest = renderedPageContext.manifest
        
        let backgroundImageModel: BackgroundImageModel?
        
        if let pageBackgroundImageResource = pageModel.backgroundImage {
            
            backgroundImageModel = BackgroundImageModel(
                backgroundImageResource: pageBackgroundImageResource,
                backgroundImageAlignment: pageModel.backgroundImageGravity,
                backgroundImageScale: pageModel.backgroundImageScaleType
            )
        }
        else if let manifestBackgroundImageResource = manifest.backgroundImage {
            
            backgroundImageModel = BackgroundImageModel(
                backgroundImageResource: manifestBackgroundImageResource,
                backgroundImageAlignment: manifest.backgroundImageGravity,
                backgroundImageScale: manifest.backgroundImageScaleType
            )
        }
        else {
            
            backgroundImageModel = nil
        }
        
        guard let model = backgroundImageModel else {
            return nil
        }
        
        return MobileContentBackgroundImageViewModel(
            backgroundImageModel: model,
            manifestResourcesCache: renderedPageContext.resourcesCache,
            languageDirection: renderedPageContext.language.languageDirection
        )
    }
    
    func buttonWithUrlTapped(url: URL) {
               
        let exitLink = ExitLinkModel(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: renderedPageContext.language.code,
            secondaryContentLanguage: nil,
            url: url
        )
                        
        renderedPageContext.navigation.buttonWithUrlTapped(url: url, exitLink: exitLink)
    }
    
    func trainingTipTapped(event: TrainingTipEvent) {
                
        renderedPageContext.navigation.trainingTipTapped(event: event)
    }
    
    func errorOccurred(error: MobileContentErrorViewModel) {
                        
        renderedPageContext.navigation.errorOccurred(error: error)
    }
}
