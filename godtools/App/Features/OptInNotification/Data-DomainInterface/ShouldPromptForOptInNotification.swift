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
    
    private static let maxPrompts: Int = 5
    
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
                
        let lastPromptedTwoMonthsAgoOrMore: Bool
                
        if let twoMonthsAgo = getDateTwoMonthsAgo() {
            lastPromptedTwoMonthsAgoOrMore = lastPrompted < twoMonthsAgo
        }
        else {
            lastPromptedTwoMonthsAgoOrMore = true
        }
        
        return Publishers.CombineLatest(
            getOnboardingTutorialIsAvailable.isAvailablePublisher(),
            checkNotificationStatus.permissionStatusPublisher()
        )
        .map { (onboardingTutorialIsAvailable: Bool, notificationStatus: PermissionStatusDomainModel) in
                        
            guard onboardingTutorialIsAvailable == false else {
                return false
            }
            
            guard promptCount < Self.maxPrompts else {
                return false
            }
            
            guard notificationStatus == .denied || notificationStatus == .undetermined  else {
                return false
            }
            
//            let shouldPrompt: Bool = lastPromptedTwoMonthsAgoOrMore || isFirstPromptAttempt
            let shouldPrompt: Bool = true
            
            return shouldPrompt
        }
        .eraseToAnyPublisher()
    }
    
    private func getDateTwoMonthsAgo() -> Date? {
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        let twoMonthsAgo: Date? = calendar.date(
            byAdding: .month,
            value: -2,
            to: currentDate
        )
        
        return twoMonthsAgo
    }
}
