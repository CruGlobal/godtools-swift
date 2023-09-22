//
//  ShareToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

class ShareToolViewModel {
        
    private let resource: ResourceModel
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
    private let getInterfaceStringUseCase: GetInterfaceStringUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let pageNumber: Int
    
    let shareMessage: ObservableValue<String> = ObservableValue(value: "")
    
    private var cancellables = Set<AnyCancellable>()
    
    init(resource: ResourceModel, language: LanguageDomainModel, pageNumber: Int, incrementUserCounterUseCase: IncrementUserCounterUseCase, getInterfaceStringUseCase: GetInterfaceStringUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
                
        self.resource = resource
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        self.getInterfaceStringUseCase = getInterfaceStringUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.pageNumber = pageNumber
        
        var shareUrlString: String = "https://knowgod.com/\(language.localeIdentifier)/\(resource.abbreviation)"

        if pageNumber > 0 {
            shareUrlString = shareUrlString.appending("/").appending("\(pageNumber)")
        }
        
        shareUrlString = shareUrlString.replacingOccurrences(of: " ", with: "").appending("?icid=gtshare ")
        
        getInterfaceStringUseCase.getStringPublisher(id: "tract_share_message")
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (tractShareMessage: String) in
                
                let shareMessageValue: String = String.localizedStringWithFormat(tractShareMessage, shareUrlString)
                self?.shareMessage.accept(value: shareMessageValue)
            }
            .store(in: &cancellables)
    }
    
    private var analyticsScreenName: String {
        return resource.abbreviation + "-" + String(pageNumber)
    }
    
    private var analyticsSiteSection: String {
        return resource.abbreviation
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
}

// MARK: - Inputs

extension ShareToolViewModel {
    
    func pageViewed() {
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
            
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.shareIconEngaged,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [
                AnalyticsConstants.Keys.shareAction: 1
            ]
        )
        
        incrementUserCounterUseCase.incrementUserCounter(for: .linkShared)
            .sink { _ in
                
            } receiveValue: { _ in

            }
            .store(in: &cancellables)
    }
}
