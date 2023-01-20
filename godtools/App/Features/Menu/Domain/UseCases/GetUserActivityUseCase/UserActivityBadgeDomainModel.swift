//
//  UserActivityBadgeDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 1/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

struct UserActivityBadgeDomainModel {
    
    let variant: Int
    let progressTarget: Int
    let isEarned: Bool
    
    // properties actually in use
    let badgeText: String
    let badgeType: Badge.BadgeType
    let progress: Int
    
    init(badge: Badge) {
        
        variant = Int(badge.variant)
        progressTarget = Int(badge.progressTarget)
        progress = Int(badge.progress)
        badgeType = badge.type
        isEarned = badge.isEarned
        badgeText = UserActivityBadgeDomainModel.getBadgeText(badgeType: badge.type, progress: progress)
    }
    
    private static func getBadgeText(badgeType: Badge.BadgeType, progress: Int) -> String {
        
        // TODO: - need singular/plural
        switch badgeType {
            
        case .toolsOpened:
            
            return "Opened \(progress) tools"
            
        case .articlesOpened:
            
            return "Opened \(progress) articles"
            
        case .imagesShared:
            
            return "Shared \(progress) images"
            
        case .lessonsCompleted:
            
            return "Completed \(progress) lessons"
            
        case .tipsCompleted:
            
            return "Completed \(progress) training tips"
            
        default:
            
            return "What is this? \(badgeType.name)"

        }
    }
}

extension UserActivityBadgeDomainModel: Identifiable {
    
    var id: String {
        return "\(badgeType.name)_\(variant)"
    }
}
