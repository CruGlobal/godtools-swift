//
//  MobileContentPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentPageViewModel: MobileContentPageViewModelType {
    
    private let pageModel: Page
    private let renderedPageContext: MobileContentRenderedPageContext
    private let deepLinkService: DeepLinkingServiceType
    private let hidesBackgroundImage: Bool
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, pageModel: Page, renderedPageContext: MobileContentRenderedPageContext, deepLinkService: DeepLinkingServiceType, hidesBackgroundImage: Bool) {
        
        self.flowDelegate = flowDelegate
        self.pageModel = pageModel
        self.renderedPageContext = renderedPageContext
        self.deepLinkService = deepLinkService
        self.hidesBackgroundImage = hidesBackgroundImage
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
    
    func buttonWithUrlTapped(url: String) {
                    
        if let webUrl = URL(string: url) {
            if deepLinkService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: webUrl))) {
                return
            }
        }
        
        let exitLink = ExitLinkModel(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            url: url
        )
        
        flowDelegate?.navigate(step: .buttonWithUrlTappedFromMobileContentRenderer(url: url, exitLink: exitLink))
    }
    
    func trainingTipTapped(event: TrainingTipEvent) {
        
        flowDelegate?.navigate(step: .trainingTipTappedFromMobileContentRenderer(event: event))
    }
    
    func errorOccurred(error: MobileContentErrorViewModel) {
        flowDelegate?.navigate(step: .errorOccurredFromMobileContentRenderer(error: error))
    }
}
