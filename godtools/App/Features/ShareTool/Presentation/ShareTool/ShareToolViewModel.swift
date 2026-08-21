//
//  ShareToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class ShareToolViewModel {
            
    private let stepEmitter: FlowStepEmitter
    private let toolId: String
    private let toolAnalyticsAbbreviation: String
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let pageNumber: Int
    
    let strings: ShareToolStringsDomainModel
    
    private var cancellables = Set<AnyCancellable>()
        
    init(
        stepEmitter: FlowStepEmitter,
        strings: ShareToolStringsDomainModel,
        toolId: String,
        toolAnalyticsAbbreviation: String,
        pageNumber: Int,
        incrementUserCounterUseCase: IncrementUserCounterUseCase,
        trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase,
        trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    ) {
             
        self.stepEmitter = stepEmitter
        self.strings = strings
        self.toolId = toolId
        self.toolAnalyticsAbbreviation = toolAnalyticsAbbreviation
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.pageNumber = pageNumber
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private var analyticsScreenName: String {
        return toolAnalyticsAbbreviation + "-" + String(pageNumber)
    }
    
    private var analyticsSiteSection: String {
        return toolAnalyticsAbbreviation
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
}

// MARK: - Inputs

extension ShareToolViewModel {
    
    func pageViewed() {
        
        let analyticsProperties = AnalyticsProperties(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            appLanguage: nil,
            contentLanguage: nil,
            secondaryContentLanguage: nil
        )
        let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase = self.trackScreenViewAnalyticsUseCase
        let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase = self.trackActionAnalyticsUseCase
        
        Task.detached {
            await trackScreenViewAnalyticsUseCase.execute(
                properties: analyticsProperties
            )
        }
            
        Task.detached {
            
            await trackActionAnalyticsUseCase.execute(
                properties: analyticsProperties,
                actionName: AnalyticsConstants.ActionNames.shareIconEngaged,
                data: [
                    AnalyticsConstants.Keys.shareAction: 1
                ]
            )
        }
        
        let incrementUserCounterUseCase: IncrementUserCounterUseCase = self.incrementUserCounterUseCase
        
        Task.detached {
            
            _ = try await incrementUserCounterUseCase.execute(interaction: .linkShared)
        }
    }
    
    func qrCodeTapped() {
    
        stepEmitter.emit(step: AppFlowStep.qrCodeTappedFromShareTool)
    }
    
    func activityViewDismissed() {
        
        stepEmitter.emit(step: AppFlowStep.dismissedShareTool)
    }
}
