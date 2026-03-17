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
    
    private let getOnboardingTutorialIsAvailableUseCase: GetOnboardingTutorialIsAvailableUseCase
    private let optInNotificationRepository: OptInNotificationRepositoryInterface
    private let getNotificationStatus: GetNotificationStatus
    
    init(getOnboardingTutorialIsAvailableUseCase: GetOnboardingTutorialIsAvailableUseCase, optInNotificationRepository: OptInNotificationRepositoryInterface, getNotificationStatus: GetNotificationStatus) {
        
        self.getOnboardingTutorialIsAvailableUseCase = getOnboardingTutorialIsAvailableUseCase
        self.optInNotificationRepository = optInNotificationRepository
        self.getNotificationStatus = getNotificationStatus
    }
    
    func execute() -> AnyPublisher<Bool, Error> {
        
        let promptCount: Int = optInNotificationRepository.getPromptCount()
        let isFirstPromptAttempt: Bool = promptCount == 0
        
        let lastPrompted: Date = optInNotificationRepository.getLastPrompted() ?? Date.distantPast
        
        let remoteTimeDate = optInNotificationRepository.getRemoteTimeInterval()
        let remotePromptLimit = optInNotificationRepository.getRemotePromptLimit()
        let remoteFeatureEnabled = optInNotificationRepository.getRemoteFeatureEnabled()
        
        return Publishers.CombineLatest(
            getOnboardingTutorialIsAvailableUseCase
                .execute()
                .setFailureType(to: Error.self),
            getNotificationStatus
                .getStatusPublisher()
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
