//
//  MobileContentPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentPageViewModel: MobileContentPageViewModelType {
    
    private let pageModel: PageModelType
    private let rendererPageModel: MobileContentRendererPageModel
    private let deepLinkService: DeepLinkingServiceType
    private let hidesBackgroundImage: Bool
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, pageModel: PageModelType, rendererPageModel: MobileContentRendererPageModel, deepLinkService: DeepLinkingServiceType, hidesBackgroundImage: Bool) {
        
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
        return rendererPageModel.pageColors.backgroundColor
    }
    
    func getFlowDelegate() -> FlowDelegate? {
        return flowDelegate
    }
    
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel? {
               
        guard !hidesBackgroundImage else {
            return nil
        }
        
        let manifestAttributes: MobileContentXmlManifestAttributes = rendererPageModel.manifest.attributes
        
        let backgroundImageNode: BackgroundImageNodeType?
        
        if pageModel.backgroundImageExists {
            backgroundImageNode = pageModel
        }
        else if manifestAttributes.backgroundImageExists {
            backgroundImageNode = manifestAttributes
        }
        else {
            backgroundImageNode = nil
        }
        
        if let backgroundImageNode = backgroundImageNode {
            return MobileContentBackgroundImageViewModel(
                backgroundImageNode: backgroundImageNode,
                manifestResourcesCache: rendererPageModel.resourcesCache,
                languageDirection: rendererPageModel.language.languageDirection
            )
        }
        
        return nil
    }
    
    func buttonWithUrlTapped(url: String) {
                    
        if let webUrl = URL(string: url) {
            if deepLinkService.parseDeepLink(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: webUrl))) {
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
