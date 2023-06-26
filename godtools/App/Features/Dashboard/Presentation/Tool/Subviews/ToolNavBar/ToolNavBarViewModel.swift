//
//  ToolNavBarViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser
import SwiftUI

class ToolNavBarViewModel: NSObject {
    
    private let backButtonImageType: ToolBackButtonImageType
    private let resource: ResourceModel
    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    private let tractRemoteShareSubscriber: TractRemoteShareSubscriber
    private let fontService: FontService
    private let analytics: AnalyticsContainer
    
    let languages: [LanguageDomainModel]
    let backButtonImage: UIImage
    let navBarColor: UIColor
    let navBarControlColor: UIColor
    let hidesChooseLanguageControl: Bool
    let remoteShareIsActive: ObservableValue<Bool> = ObservableValue(value: false)
    let selectedLanguage: ObservableValue<Int>
    
    init(backButtonImageType: ToolBackButtonImageType, resource: ResourceModel, manifest: Manifest, languages: [LanguageDomainModel], tractRemoteSharePublisher: TractRemoteSharePublisher, tractRemoteShareSubscriber: TractRemoteShareSubscriber, fontService: FontService, analytics: AnalyticsContainer, selectedLanguageValue: Int?) {
        
        self.backButtonImageType = backButtonImageType
        self.resource = resource
        self.languages = languages
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.tractRemoteShareSubscriber = tractRemoteShareSubscriber
        self.fontService = fontService
        self.analytics = analytics
        self.selectedLanguage = ObservableValue(value: selectedLanguageValue ?? 0)
        
        backButtonImage = backButtonImageType.getImage()
        navBarColor = manifest.navBarColor
        navBarControlColor = manifest.navBarControlColor
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
    
    var navTitle: String? {
        return nil
    } 
    
    var numberOfLanguages: Int {
        return languages.count
    }
    
    var navBarFont: UIFont {
        return fontService.getFont(size: 17, weight: .semibold)
    }
    
    var language: LanguageDomainModel {
        return languages[selectedLanguage.value]
    }
    
    var languageControlFont: UIFont {
        return fontService.getFont(size: 14, weight: .regular)
    }
}

// MARK: - Inputs

extension ToolNavBarViewModel {
    
    func languageSegmentWillAppear(index: Int) -> ToolLanguageSegmentViewModel {
                
        return ToolLanguageSegmentViewModel(
            language: languages[index]
        )
    }
    
    func languageTapped(index: Int) {
                
        selectedLanguage.setValue(value: index)
        
        let language: LanguageDomainModel = languages[index]
        
        let data: [String: String] = [
            AnalyticsConstants.ActionNames.parallelLanguageToggled: "",
            AnalyticsConstants.Keys.contentLanguageSecondary: language.localeIdentifier,
        ]
        
        let trackAction = TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.parallelLanguageToggled,
            siteSection: analyticsSiteSection,
            siteSubSection: "",
            contentLanguage: language.localeIdentifier,
            secondaryContentLanguage: nil,
            url: nil,
            data: data
        )
        
        analytics.trackActionAnalytics.trackAction(trackAction: trackAction)
    }
}
