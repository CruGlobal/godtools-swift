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
        
        if progressTarget == 1 {
            
            return getSingularString(for: badgeType)
            
        } else {
            
            return getPluralString(for: badgeType, progressTarget: progressTarget)
        }
    }
    
    private func getPluralString(for badgeType: Badge.BadgeType, progressTarget: Int) -> String {
        
        let stringToFormat: String
        
        switch badgeType {
            
        case .articlesOpened:
            
            stringToFormat = localizationServices.stringForMainBundle(key: "badges.articlesOpened.plural")
        
        case .imagesShared:
            
            stringToFormat = localizationServices.stringForMainBundle(key: "badges.imagesShared.plural")
        
        case .lessonsCompleted:
            
            stringToFormat = localizationServices.stringForMainBundle(key: "badges.lessonsCompleted.plural")
        
        case .toolsOpened:
            
            stringToFormat = localizationServices.stringForMainBundle(key: "badges.toolsOpened.plural")
   
        case .tipsCompleted:
            
            stringToFormat = localizationServices.stringForMainBundle(key: "badges.tipsCompleted.plural")
            
        default:
            
            stringToFormat = ""

        }
        
        return String.localizedStringWithFormat(
            stringToFormat,
            progressTarget
        )
    }
    
    private func getSingularString(for badgeType: Badge.BadgeType) -> String {
        
        switch badgeType {
            
        case .articlesOpened:
            
            return localizationServices.stringForMainBundle(key: "badges.articlesOpened.singular")
        
        case .imagesShared:
            
            return localizationServices.stringForMainBundle(key: "badges.imagesShared.singular")
        
        case .lessonsCompleted:
            
            return localizationServices.stringForMainBundle(key: "badges.lessonsCompleted.singular")
        
        case .toolsOpened:
            
            return localizationServices.stringForMainBundle(key: "badges.toolsOpened.singular")
   
        case .tipsCompleted:
            
            return localizationServices.stringForMainBundle(key: "badges.tipsCompleted.singular")
            
        default:
            
            return ""

        }
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
