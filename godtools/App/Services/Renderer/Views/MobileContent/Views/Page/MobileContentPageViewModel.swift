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
    private let rendererPageModel: MobileContentRendererPageModel
    private let deepLinkService: DeepLinkingServiceType
    private let hidesBackgroundImage: Bool
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, pageModel: Page, rendererPageModel: MobileContentRendererPageModel, deepLinkService: DeepLinkingServiceType, hidesBackgroundImage: Bool) {
        
        self.flowDelegate = flowDelegate
        self.pageModel = pageModel
        self.rendererPageModel = rendererPageModel
        self.deepLinkService = deepLinkService
        self.hidesBackgroundImage = hidesBackgroundImage
    }
    
    var analyticsScreenName: String {
        
        let resource: ResourceModel = rendererPageModel.resource
        let page: Int = rendererPageModel.page
        
        return resource.abbreviation + "-" + String(page)
    }
    
    var analyticsSiteSection: String {
        
        let resource: ResourceModel = rendererPageModel.resource
 
        return resource.abbreviation
    }
    
    var backgroundColor: UIColor {
        return pageModel.backgroundColor
    }
    
    func getFlowDelegate() -> FlowDelegate? {
        return flowDelegate
    }
    
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel? {
               
        guard !hidesBackgroundImage else {
            return nil
        }
        
        let manifest: Manifest = rendererPageModel.manifest
        
        let backgroundImageModel: BackgroundImageModel?
        
        if let pageBackgroundImageFileName = pageModel.backgroundImage?.name {
            
            backgroundImageModel = BackgroundImageModel(
                backgroundImageFileName: pageBackgroundImageFileName,
                backgroundImageAlignment: pageModel.backgroundImageGravity,
                backgroundImageScale: pageModel.backgroundImageScaleType
            )
        }
        else if let manifestBackgroundImageFileName = manifest.backgroundImage?.name {
            
            backgroundImageModel = BackgroundImageModel(
                backgroundImageFileName: manifestBackgroundImageFileName,
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
            manifestResourcesCache: rendererPageModel.resourcesCache,
            languageDirection: rendererPageModel.language.languageDirection
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
            siteSubSection: "",
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
