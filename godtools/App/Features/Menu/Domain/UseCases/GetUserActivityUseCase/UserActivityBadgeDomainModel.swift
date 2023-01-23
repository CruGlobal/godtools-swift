//
//  UserActivityBadgeDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 1/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser
import SwiftUI

struct UserActivityBadgeDomainModel {
    
    let variant: Int
    let progressTarget: Int
    let isEarned: Bool
    
    // properties actually in use
    let badgeText: String
    let badgeType: Badge.BadgeType
    let iconBackgroundColor: Color
    let iconForegroundColor: Color
    let iconImageName: String
    
    init(badge: Badge) {
        
        variant = Int(badge.variant)
        progressTarget = Int(badge.progressTarget)
        isEarned = badge.isEarned
        badgeType = badge.type
        badgeText = UserActivityBadgeDomainModel.getBadgeText(badgeType: badgeType, progress: Int(badge.progress))
        iconBackgroundColor = Color(badge.colors.containerColor(mode: .light))
        iconForegroundColor = Color(badge.colors.color(mode: .light))
        iconImageName = UserActivityBadgeDomainModel.getIconImageName(badgeType: badgeType, variant: variant)
        
    }
    
    private static func getIconImageName(badgeType: Badge.BadgeType, variant: Int) -> String {
        
        switch badgeType {
            
        case .toolsOpened:
            
            return "tools-\(variant)"
            
        case .articlesOpened:
            
            return "articles-\(variant)"
            
        case .imagesShared:
            
            return "share-images-\(variant)"
            
        case .lessonsCompleted:
            
            return "lesson-\(variant)"
            
        case .tipsCompleted:
            
            return "tips-\(variant)"
            
        default:
            
            return "tools-\(variant)"

        }
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
