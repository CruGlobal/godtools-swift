//
//  ShouldPromptForOptInNotificationUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 4/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class ShouldPromptForOptInNotificationUseCase {
    
    private let getOnboardingTutorialIsAvailable: GetOnboardingTutorialIsAvailable
    private let optInNotificationRepository: OptInNotificationRepositoryInterface
    private let getNotificationStatus: GetNotificationStatus
    
    init(getOnboardingTutorialIsAvailable: GetOnboardingTutorialIsAvailable, optInNotificationRepository: OptInNotificationRepositoryInterface, getNotificationStatus: GetNotificationStatus) {
        
        self.getOnboardingTutorialIsAvailable = getOnboardingTutorialIsAvailable
        self.optInNotificationRepository = optInNotificationRepository
        self.getNotificationStatus = getNotificationStatus
    }
    
    func execute() async throws -> Bool {
        
        let onboardingTutorialIsAvailable: Bool = getOnboardingTutorialIsAvailable.getIsAvailable()
        
        let promptCount: Int = optInNotificationRepository.getPromptCount()
        let isFirstPromptAttempt: Bool = promptCount == 0
        
        let lastPrompted: Date = optInNotificationRepository.getLastPrompted() ?? Date.distantPast
        
        let remoteTimeDate = optInNotificationRepository.getRemoteTimeInterval()
        let remotePromptLimit = optInNotificationRepository.getRemotePromptLimit()
        let remoteFeatureEnabled = optInNotificationRepository.getRemoteFeatureEnabled()
        
        let notificationStatus: PermissionStatusDomainModel = try await getNotificationStatus.getStatus()
        
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
}
