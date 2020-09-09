//
//  BaseTractElementDiContainer.swift
//  godtools
//

import Foundation

class BaseTractElementDiContainer {
    
    let config: TractConfigurations
    let isNewUserService: IsNewUserService
    let followUpsService: FollowUpsService
    let analytics: AnalyticsContainer
    let cardJumpService: CardJumpService
    
    required init(config: TractConfigurations, isNewUserService: IsNewUserService, cardJumpService: CardJumpService, followUpsService: FollowUpsService, analytics: AnalyticsContainer) {
        
        self.config = config
        self.isNewUserService = isNewUserService
        self.cardJumpService = cardJumpService
        self.followUpsService = followUpsService
        self.analytics = analytics
    }
}
