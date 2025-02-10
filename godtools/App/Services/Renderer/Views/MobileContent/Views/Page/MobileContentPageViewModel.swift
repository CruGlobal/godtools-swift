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
    
    enum BackgroundImageType {
        case background
        case foreground
    }
    
    private let pageModel: Page
    private let visibleAnalyticsEventsObjects: [MobileContentRendererAnalyticsEvent]
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let hidesBackgroundImage: Bool
    
        
    init(pageModel: Page, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, hidesBackgroundImage: Bool) {
        
        self.pageModel = pageModel
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.hidesBackgroundImage = hidesBackgroundImage
        
        self.visibleAnalyticsEventsObjects = MobileContentRendererAnalyticsEvent.initAnalyticsEvents(
            analyticsEvents: pageModel.getAnalyticsEvents(type: .visible),
            mobileContentAnalytics: mobileContentAnalytics,
            renderedPageContext: renderedPageContext
        )
        
        super.init(baseModel: pageModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
    
    var analyticsScreenName: String {
        
        let resource: ResourceModel = renderedPageContext.resource
        let page: Int32 = renderedPageContext.pageModel.position
        
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
    
    func getBackgroundImage(type: BackgroundImageType) -> MobileContentBackgroundImageViewModel? {
        
        guard !hidesBackgroundImage else {
            return nil
        }
        
        let backgroundImageModel: BackgroundImageModel?
        
        switch type {
       
        case .background:
            
            let manifest: Manifest = renderedPageContext.manifest
            if let manifestBackgroundImageResource = manifest.backgroundImage {
                backgroundImageModel = BackgroundImageModel(
                    backgroundImageResource: manifestBackgroundImageResource,
                    backgroundImageAlignment: manifest.backgroundImageGravity,
                    backgroundImageScale: manifest.backgroundImageScaleType
                )
            }
            else {
                backgroundImageModel = nil
            }
            
        case .foreground:
            
            if let pageBackgroundImageResource = pageModel.backgroundImage {
                backgroundImageModel = BackgroundImageModel(
                    backgroundImageResource: pageBackgroundImageResource,
                    backgroundImageAlignment: pageModel.backgroundImageGravity,
                    backgroundImageScale: pageModel.backgroundImageScaleType
                )
            }
            else {
                backgroundImageModel = nil
            }
        }

        guard let backgroundImageModel = backgroundImageModel else {
            return nil
        }
        
        return MobileContentBackgroundImageViewModel(
            backgroundImageModel: backgroundImageModel,
            manifestResourcesCache: renderedPageContext.resourcesCache,
            languageDirection: LanguageDirectionDomainModel(languageModel: renderedPageContext.language)
        )
    }
    
    func pageDidAppear() {
     
        super.viewDidAppear(visibleAnalyticsEvents: visibleAnalyticsEventsObjects)
        
        trackScreenAnalytics()
    }
    
    func trackScreenAnalytics() {
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            appLanguage: renderedPageContext.appLanguage,
            contentLanguage: renderedPageContext.rendererLanguages.primaryLanguage.localeId,
            contentLanguageSecondary: renderedPageContext.rendererLanguages.parallelLanguage?.localeId
        )
    }
}

// MARK: - Inputs

extension MobileContentPageViewModel {
    
    func buttonWithUrlTapped(url: URL) {
                             
        renderedPageContext.navigation.buttonWithUrlTapped(
            url: url,
            analyticsScreenName: analyticsScreenName,
            analyticsSiteSection: analyticsSiteSection,
            analyticsSiteSubSection: analyticsSiteSubSection,
            languages: renderedPageContext.rendererLanguages
        )
    }
    
    func trainingTipTapped(event: TrainingTipEvent) {
                
        renderedPageContext.navigation.trainingTipTapped(event: event)
    }
    
    func errorOccurred(error: MobileContentErrorViewModel) {
                        
        renderedPageContext.navigation.errorOccurred(error: error)
    }
}
