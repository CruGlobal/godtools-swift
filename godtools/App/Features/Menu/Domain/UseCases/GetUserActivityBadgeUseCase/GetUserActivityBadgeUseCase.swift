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
    
    private let localizationServices: LocalizationServices
    
    private let lightGreyTextColor = Color(red: 203 / 255, green: 203 / 255, blue: 203 / 255)
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getBadge(from godToolsSharedLibraryBadge: Badge) -> UserActivityBadgeDomainModel {
        
        let badgeType = godToolsSharedLibraryBadge.type
        let variant = Int(godToolsSharedLibraryBadge.variant)
        
        let badgeText = getBadgeText(badgeType: badgeType, progressTarget: Int(godToolsSharedLibraryBadge.progressTarget))
        let iconName = getIconImageName(badgeType: badgeType, variant: variant)
        
        let iconBackgroundColor = Color(godToolsSharedLibraryBadge.colors.containerColor(mode: .light))
        let iconForegroundColor = Color(godToolsSharedLibraryBadge.colors.color(mode: .light))
        
        let identifiableId = "\(badgeType.name)_\(variant)"
        let isEarned = godToolsSharedLibraryBadge.isEarned
        
        return UserActivityBadgeDomainModel(
            badgeText: badgeText,
            iconBackgroundColor: iconBackgroundColor,
            iconForegroundColor: iconForegroundColor,
            iconImageName: iconName,
            id: identifiableId,
            isEarned: isEarned,
            textColor: isEarned ? ColorPalette.gtGrey.color : lightGreyTextColor
        )
    }
    
    private func getBadgeText(badgeType: Badge.BadgeType, progressTarget: Int) -> String {
        
        if progressTarget == 1 {
            
            return getSingularString(for: badgeType)
            
        } else {
            
            return getPluralString(for: badgeType, progressTarget: progressTarget)
        }
    }
    
    private func getSingularString(for badgeType: Badge.BadgeType) -> String {
        
        let stringLocalizationKey: String
        
        switch badgeType {
            
        case .articlesOpened:
            
            stringLocalizationKey = "badges.articlesOpened.singular"
        
        case .imagesShared:
            
            stringLocalizationKey = "badges.imagesShared.singular"
        
        case .lessonsCompleted:
            
            stringLocalizationKey = "badges.lessonsCompleted.singular"
        
        case .toolsOpened:
            
            stringLocalizationKey = "badges.toolsOpened.singular"
   
        case .tipsCompleted:
            
            stringLocalizationKey = "badges.tipsCompleted.singular"
            
        default:
            
            return ""

        }
        
        return localizationServices.stringForMainBundle(key: stringLocalizationKey)
    }
    
    private func getPluralString(for badgeType: Badge.BadgeType, progressTarget: Int) -> String {
        
        let stringLocalizationKey: String
        
        switch badgeType {
            
        case .articlesOpened:
            
            stringLocalizationKey = "badges.articlesOpened.plural"
        
        case .imagesShared:
            
            stringLocalizationKey = "badges.imagesShared.plural"
        
        case .lessonsCompleted:
            
            stringLocalizationKey = "badges.lessonsCompleted.plural"
        
        case .toolsOpened:
            
            stringLocalizationKey = "badges.toolsOpened.plural"
   
        case .tipsCompleted:
            
            stringLocalizationKey = "badges.tipsCompleted.plural"
            
        default:
            
            return ""

        }
        
        return String.localizedStringWithFormat(
            localizationServices.stringForMainBundle(key: stringLocalizationKey),
            progressTarget
        )
    }
    
    private func getIconImageName(badgeType: Badge.BadgeType, variant: Int) -> String {
        
        switch badgeType {
            
        case .articlesOpened:
            
            return "articles-\(variant)"
            
        case .imagesShared:
            
            return "share-images-\(variant)"
        
        case .lessonsCompleted:
            
            return "lesson-\(variant)"
       
        case .toolsOpened:
            
            return "tools-\(variant)"
            
        case .tipsCompleted:
            
            return "tips-\(variant)"
            
        default:
            
            return "tools-\(variant)"

        }
    }

}
