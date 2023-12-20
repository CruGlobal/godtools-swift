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
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let pageNumber: Int
    
    let shareMessage: String
    
    private var cancellables = Set<AnyCancellable>()
    
    init(viewShareToolDomainModel: ViewShareToolDomainModel, resource: ResourceModel, pageNumber: Int, incrementUserCounterUseCase: IncrementUserCounterUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
                
        self.resource = resource
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.pageNumber = pageNumber
                
        shareMessage = viewShareToolDomainModel.interfaceStrings.shareMessage
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
