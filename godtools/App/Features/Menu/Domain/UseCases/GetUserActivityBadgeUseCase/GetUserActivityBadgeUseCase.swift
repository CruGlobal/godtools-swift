//
//  GetUserActivityBadgeUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 1/24/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser
import SwiftUI

class GetUserActivityBadgeUseCase {
    
    func getBadge(from godToolsSharedLibraryBadge: Badge) -> UserActivityBadgeDomainModel {
        
        let badgeType = godToolsSharedLibraryBadge.type
        let variant = Int(godToolsSharedLibraryBadge.variant)
        
        let badgeText = getBadgeText(badgeType: badgeType, progressTarget: Int(godToolsSharedLibraryBadge.progressTarget))
        let iconName = getIconImageName(badgeType: badgeType, variant: variant)
        
        let iconBackgroundColor = Color(godToolsSharedLibraryBadge.colors.containerColor(mode: .light))
        let iconForegroundColor = Color(godToolsSharedLibraryBadge.colors.color(mode: .light))
        
        return UserActivityBadgeDomainModel(
            badgeText: badgeText,
            badgeType: badgeType,
            iconBackgroundColor: iconBackgroundColor,
            iconForegroundColor: iconForegroundColor,
            iconImageName: iconName,
            isEarned: godToolsSharedLibraryBadge.isEarned,
            variant: variant
        )
    }
    
    
    private func getBadgeText(badgeType: Badge.BadgeType, progressTarget: Int) -> String {
        
        // TODO: - need singular/plural
        switch badgeType {
            
        case .toolsOpened:
            
            return "Opened \(progressTarget) tools"
            
        case .articlesOpened:
            
            return "Opened \(progressTarget) articles"
            
        case .imagesShared:
            
            return "Shared \(progressTarget) images"
            
        case .lessonsCompleted:
            
            return "Completed \(progressTarget) lessons"
            
        case .tipsCompleted:
            
            return "Completed \(progressTarget) training tips"
            
        default:
            
            return "What is this? \(badgeType.name)"

        }
    }
    
    private func getIconImageName(badgeType: Badge.BadgeType, variant: Int) -> String {
        
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

}
