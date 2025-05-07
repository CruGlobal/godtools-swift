//
//  ShouldPromptForOptInNotification.swift
//  godtools
//
//  Created by Levi Eggert on 4/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class ShouldPromptForOptInNotification: ShouldPromptForOptInNotificationInterface {
    
    private let getOnboardingTutorialIsAvailable: GetOnboardingTutorialIsAvailableInterface
    private let optInNotificationRepository: OptInNotificationRepositoryInterface
    private let checkNotificationStatus: GetCheckNotificationStatusInterface
    
    init(getOnboardingTutorialIsAvailable: GetOnboardingTutorialIsAvailableInterface, optInNotificationRepository: OptInNotificationRepositoryInterface, checkNotificationStatus: GetCheckNotificationStatusInterface) {
        
        self.getOnboardingTutorialIsAvailable = getOnboardingTutorialIsAvailable
        self.optInNotificationRepository = optInNotificationRepository
        self.checkNotificationStatus = checkNotificationStatus
    }
    
    func shouldPromptPublisher() -> AnyPublisher<Bool, Never> {
        
        let promptCount: Int = optInNotificationRepository.getPromptCount()
        let isFirstPromptAttempt: Bool = promptCount == 0
        
        let lastPrompted: Date = optInNotificationRepository.getLastPrompted() ?? Date.distantPast
        
        let remoteTimeDate = optInNotificationRepository.getRemoteTimeInterval()
        let remotePromptLimit = optInNotificationRepository.getRemotePromptLimit()
        let remoteFeatureEnabled = optInNotificationRepository.getRemoteFeatureEnabled()
        
        return Publishers.CombineLatest(
            getOnboardingTutorialIsAvailable.isAvailablePublisher(),
            checkNotificationStatus.permissionStatusPublisher()
        )
        .map { (onboardingTutorialIsAvailable: Bool, notificationStatus: PermissionStatusDomainModel) in
                      
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
