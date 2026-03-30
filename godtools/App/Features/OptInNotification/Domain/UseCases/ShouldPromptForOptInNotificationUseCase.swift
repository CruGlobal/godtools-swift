//
//  ShouldPromptForOptInNotificationUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 4/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

final class ShouldPromptForOptInNotificationUseCase {
    
    private let getOnboardingTutorialIsAvailable: GetOnboardingTutorialIsAvailable
    private let optInNotificationRepository: OptInNotificationRepositoryInterface
    private let getNotificationStatus: GetNotificationStatus
    
    init(getOnboardingTutorialIsAvailable: GetOnboardingTutorialIsAvailable, optInNotificationRepository: OptInNotificationRepositoryInterface, getNotificationStatus: GetNotificationStatus) {
        
        self.getOnboardingTutorialIsAvailable = getOnboardingTutorialIsAvailable
        self.optInNotificationRepository = optInNotificationRepository
        self.getNotificationStatus = getNotificationStatus
    }
    
    func execute() -> AnyPublisher<Bool, Error> {
        
        let onboardingTutorialIsAvailable: Bool = getOnboardingTutorialIsAvailable.getIsAvailable()
        
        let promptCount: Int = optInNotificationRepository.getPromptCount()
        let isFirstPromptAttempt: Bool = promptCount == 0
        
        let lastPrompted: Date = optInNotificationRepository.getLastPrompted() ?? Date.distantPast
        
        let remoteTimeDate = optInNotificationRepository.getRemoteTimeInterval()
        let remotePromptLimit = optInNotificationRepository.getRemotePromptLimit()
        let remoteFeatureEnabled = optInNotificationRepository.getRemoteFeatureEnabled()
        
        return getNotificationStatus
            .getStatusPublisher()
            .map { (notificationStatus: PermissionStatusDomainModel) in
                          
                guard onboardingTutorialIsAvailable == false else {
                    return false
                }
                
                guard remoteFeatureEnabled == true else {
                    return false
                }
                
                guard promptCount < remotePromptLimit else {
                    return false
                }
                
                guard notificationStatus == .denied || notificationStatus == .undetermined else {
                    return false
                }
                
                return lastPrompted < remoteTimeDate || isFirstPromptAttempt
            }
            .eraseToAnyPublisher()
    }
}
