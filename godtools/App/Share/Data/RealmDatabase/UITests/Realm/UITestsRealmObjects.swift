//
//  UITestsRealmObjects.swift
//  godtools
//
//  Created by Levi Eggert on 2/23/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift

final class UITestsRealmObjects {
    
    private static let resource1: String = "ui_test_resource_1"
    private static let resource2: String = "ui_test_resource_2"
    private static let resource3: String = "ui_test_resource_3"
    
    static func getAllObjects() -> [Object] {
        
        return Self.getAppLanguages() +
        Self.getResources() +
        Self.getFavoritedResources() +
        Self.getLanguages()
    }
}

// MARK: - App Languages

extension UITestsRealmObjects {
    
    private static func getAppLanguages() -> [RealmAppLanguage] {
        return [
            Self.getAppLanguage(languageCode: "en")
        ]
    }
    
    private static func getAppLanguage(languageCode: String) -> RealmAppLanguage {
        
        let object = RealmAppLanguage()
        
        object.id = languageCode
        object.languageCode = languageCode
        object.languageId = languageCode
        
        return object
    }
}

// MARK: - Resources

extension UITestsRealmObjects {
    
    private static func getResources() -> [RealmResource] {
        
        return [
            Self.getKgpTool(),
            Self.getTeachMeToShareTool(),
            Self.getFourSpiritualLawsTool()
        ]
    }
    
    private static func getKgpTool() -> RealmResource {
        
        let resource = RealmResource()
        
        resource.abbreviation = "kgp"
        resource.attrCategory = "gospel"
        resource.attrSpotlight = true
        resource.id = Self.resource1
        resource.isHidden = false
        resource.name = AccessibilityStrings.Button.ToolName.knowingGodPersonally.rawValue
        resource.resourceDescription = "A Gospel presentation that uses hand drawn images to help illustrate God's invitation to know Him personally. \n\nConversation starter: Has anyone ever shared with you how you can know God personally?\n\nAll Bible references are from the New Living Translation."
        resource.resourceType = ResourceType.tract.rawValue
        resource.totalViews = 12579
        
        return resource
    }
    
    private static func getTeachMeToShareTool() -> RealmResource {
        
        let resource = RealmResource()
        
        resource.abbreviation = "teachmetoshare"
        resource.attrCategory = "training"
        resource.attrSpotlight = true
        resource.id = Self.resource2
        resource.isHidden = false
        resource.name = AccessibilityStrings.Button.ToolName.teachMeToShare.rawValue
        resource.resourceDescription = "Training tips on how to share your faith."
        resource.resourceType = ResourceType.tract.rawValue
        resource.totalViews = 615670
        
        return resource
    }
    
    private static func getFourSpiritualLawsTool() -> RealmResource {
        
        let resource = RealmResource()
        
        resource.abbreviation = "fourlaws"
        resource.attrCategory = "gospel"
        resource.attrSpotlight = false
        resource.id = Self.resource3
        resource.isHidden = false
        resource.name = AccessibilityStrings.Button.ToolName.fourSpiritualLaws.rawValue
        resource.resourceDescription = "Classic gospel presentation of God's invitation to those who don't yet know him. \n\nConversation starter: I have a summary of the Bible's message using four simple ideas. May I share it with you?\n\nAll Bible references are from the New American Standard Bible unless otherwise stated."
        resource.resourceType = ResourceType.tract.rawValue
        resource.totalViews = 2533146
        
        return resource
    }
}

// MARK: - Favorited Resources

extension UITestsRealmObjects {
    
    private static func getFavoritedResources() -> [RealmFavoritedResource] {
        return [
            Self.getFavoritedResource(resourceId: Self.resource3, position: 0)
        ]
    }
    
    private static func getFavoritedResource(resourceId: String, position: Int) -> RealmFavoritedResource {
        
        let object = RealmFavoritedResource()
        
        object.id = resourceId
        object.resourceId = resourceId
        object.position = position
        
        return object
    }
}


// MARK: - Languages

extension UITestsRealmObjects {
    
    private static func getLanguages() -> [RealmLanguage] {
     
        let english = RealmLanguage()
        
        english.code = "en"
        english.directionString = "ltr"
        english.id = "ui_test_language_1"
        english.name = "English"
        
        return [english]
    }
}
