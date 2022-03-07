//
//  ToolNavBarViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolNavBarViewModel: NSObject, ToolNavBarViewModelType {
    
    private let backButtonImageType: ToolBackButtonImageType
    private let resource: ResourceModel
    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    private let tractRemoteShareSubscriber: TractRemoteShareSubscriber
    private let localizationServices: LocalizationServices
    private let fontService: FontService
    private let analytics: AnalyticsContainer
    
    let languages: [LanguageModel]
    let backButtonImage: UIImage
    let navBarColor: UIColor
    let navBarControlColor: UIColor
    let hidesChooseLanguageControl: Bool
    let remoteShareIsActive: ObservableValue<Bool> = ObservableValue(value: false)
    let selectedLanguage: ObservableValue<Int> = ObservableValue(value: 0)
    let hidesShareButton: Bool
    
    required init(backButtonImageType: ToolBackButtonImageType, resource: ResourceModel, manifestAttributes: MobileContentManifestAttributesType, languages: [LanguageModel], tractRemoteSharePublisher: TractRemoteSharePublisher, tractRemoteShareSubscriber: TractRemoteShareSubscriber, localizationServices: LocalizationServices, fontService: FontService, analytics: AnalyticsContainer, hidesShareButton: Bool) {
        
        self.backButtonImageType = backButtonImageType
        self.resource = resource
        self.languages = languages
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.tractRemoteShareSubscriber = tractRemoteShareSubscriber
        self.localizationServices = localizationServices
        self.fontService = fontService
        self.analytics = analytics
        self.hidesShareButton = hidesShareButton
        
        backButtonImage = backButtonImageType.getImage()
        navBarColor = manifestAttributes.navbarColor?.uiColor ?? manifestAttributes.primaryColor.uiColor
        navBarControlColor = manifestAttributes.navbarControlColor?.uiColor ?? manifestAttributes.primaryTextColor.uiColor
        hidesChooseLanguageControl = languages.count <= 1
        
        super.init()
        
        setupBinding()
        
        reloadRemoteShareIsActive()
    }
    
    deinit {
        tractRemoteSharePublisher.didCreateNewSubscriberChannelIdForPublish.removeObserver(self)
        tractRemoteShareSubscriber.subscribedToChannelObserver.removeObserver(self)
    }
    
    private var analyticsScreenName: String {
        return ""
    }
    
    private var analyticsSiteSection: String {
        return resource.abbreviation
    }
    
    private func setupBinding() {
        
        tractRemoteSharePublisher.didCreateNewSubscriberChannelIdForPublish.addObserver(self) { [weak self] (channel: TractRemoteShareChannel) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadRemoteShareIsActive()
            }
        }
        
        tractRemoteShareSubscriber.subscribedToChannelObserver.addObserver(self) { [weak self] (isSubscribed: Bool) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadRemoteShareIsActive()
            }
        }
    }
    
    private func reloadRemoteShareIsActive() {
        
        let isActive: Bool = tractRemoteSharePublisher.isSubscriberChannelIdCreatedForPublish || tractRemoteShareSubscriber.isSubscribedToChannel
        
        remoteShareIsActive.accept(value: isActive)
    }
    
    var navTitle: String {
        return "GodTools"
    }
    
    var numberOfLanguages: Int {
        return languages.count
    }
    
    var navBarFont: UIFont {
        return fontService.getFont(size: 17, weight: .semibold)
    }
    
    var language: LanguageModel {
        return languages[selectedLanguage.value]
    }
    
    var languageControlFont: UIFont {
        return fontService.getFont(size: 14, weight: .regular)
    }
    
    func languageSegmentWillAppear(index: Int) -> ToolLanguageSegmentViewModel {
        
        let language: LanguageModel = languages[index]
        
        return ToolLanguageSegmentViewModel(language: language, localizationServices: localizationServices)
    }
    
    func languageTapped(index: Int) {
                
        selectedLanguage.setValue(value: index)
        
        let language: LanguageModel = languages[index]
        
        let data: [String: String] = [
            AnalyticsConstants.ActionNames.parallelLanguageToggle: "",
            AnalyticsConstants.Keys.contentLanguageSecondary: language.code,
        ]
        
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: analyticsScreenName, actionName: AnalyticsConstants.ActionNames.parallelLanguageToggle, siteSection: analyticsSiteSection, siteSubSection: "", url: nil, data: data)
        )
    }
}
