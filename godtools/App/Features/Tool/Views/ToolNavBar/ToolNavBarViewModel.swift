//
//  ToolNavBarViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolNavBarViewModel: NSObject, ToolNavBarViewModelType {
    
    private let resource: ResourceModel
    private let languages: [LanguageModel]
    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    private let tractRemoteShareSubscriber: TractRemoteShareSubscriber
    private let localizationServices: LocalizationServices
    private let fontService: FontService
    private let analytics: AnalyticsContainer
    
    let navBarColor: UIColor
    let navBarControlColor: UIColor
    let hidesChooseLanguageControl: Bool
    let remoteShareIsActive: ObservableValue<Bool> = ObservableValue(value: false)
    let selectedLanguage: ObservableValue<Int> = ObservableValue(value: 0)
    let hidesShareButton: Bool
    
    required init(resource: ResourceModel, manifestAttributes: MobileContentManifestAttributesType, languages: [LanguageModel], tractRemoteSharePublisher: TractRemoteSharePublisher, tractRemoteShareSubscriber: TractRemoteShareSubscriber, localizationServices: LocalizationServices, fontService: FontService, analytics: AnalyticsContainer, hidesShareButton: Bool) {
        
        self.resource = resource
        self.languages = languages
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.tractRemoteShareSubscriber = tractRemoteShareSubscriber
        self.localizationServices = localizationServices
        self.fontService = fontService
        self.analytics = analytics
        self.hidesShareButton = hidesShareButton
        
        navBarColor = manifestAttributes.getNavBarColor()?.color ?? manifestAttributes.getPrimaryColor().color
        navBarControlColor = manifestAttributes.getNavBarControlColor()?.color ?? manifestAttributes.getPrimaryTextColor().color
        hidesChooseLanguageControl = languages.count <= 1
        
        super.init()
        
        setupBinding()
        
        reloadRemoteShareIsActive()
    }
    
    deinit {
        tractRemoteSharePublisher.didCreateNewSubscriberChannelIdForPublish.removeObserver(self)
        tractRemoteShareSubscriber.subscribedToChannelObserver.removeObserver(self)
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
            AdobeAnalyticsConstants.Keys.parallelLanguageToggle: "",
            AdobeAnalyticsProperties.CodingKeys.contentLanguageSecondary.rawValue: language.code,
            AdobeAnalyticsProperties.CodingKeys.siteSection.rawValue: resource.abbreviation
        ]
        
        analytics.trackActionAnalytics.trackAction(
            screenName: nil,
            actionName: AdobeAnalyticsConstants.Values.parallelLanguageToggle,
            data: data
        )
    }
}
