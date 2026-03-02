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
    
    static let tmtsTract: String = "ui_test_resource_1"
    static let fslTract: String = "ui_test_resource_2"
    static let tmtsEnTranslation: String = "tmts_en_translation"
    static let tmtsManifest: String = "tmts_manifest"
    static let fslEnTranslation: String = "fsl_en_translation"
    static let fslManifest: String = "fsl_manifest"
    
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
            Self.getTeachMeToShareTool(),
            Self.getFourSpiritualLawsTool()
        ]
    }
    
    private static func getTeachMeToShareTool() -> RealmResource {
        
        let resource = RealmResource()
        
        resource.abbreviation = "teachmetoshare"
        resource.attrCategory = "training"
        resource.attrSpotlight = true
        resource.id = Self.tmtsTract
        resource.isHidden = false
        resource.name = AccessibilityStrings.Button.ToolName.teachMeToShare.rawValue
        resource.resourceDescription = "Training tips on how to share your faith."
        resource.resourceType = ResourceType.tract.rawValue
        resource.totalViews = 615670
        
        let tmtsTranslation: RealmTranslation = getTMTSTranslation()
        let english: RealmLanguage = getEnglishLanguage()
        
        resource.addLatestTranslation(translation: tmtsTranslation)
        resource.addLanguage(language: english)
        
        tmtsTranslation.language = english
        tmtsTranslation.resource = resource
        
        return resource
    }
    
    private static func getFourSpiritualLawsTool() -> RealmResource {
        
        let resource = RealmResource()
        
        resource.abbreviation = "fourlaws"
        resource.attrCategory = "gospel"
        resource.attrSpotlight = false
        resource.id = Self.fslTract
        resource.isHidden = false
        resource.name = AccessibilityStrings.Button.ToolName.fourSpiritualLaws.rawValue
        resource.resourceDescription = "Classic gospel presentation of God's invitation to those who don't yet know him. \n\nConversation starter: I have a summary of the Bible's message using four simple ideas. May I share it with you?\n\nAll Bible references are from the New American Standard Bible unless otherwise stated."
        resource.resourceType = ResourceType.tract.rawValue
        resource.totalViews = 2533146
        
        let fslTranslation: RealmTranslation = getFSLTranslation()
        let english: RealmLanguage = getEnglishLanguage()
        
        resource.addLatestTranslation(translation: fslTranslation)
        resource.addLanguage(language: english)
        
        fslTranslation.language = english
        fslTranslation.resource = resource
        
        return resource
    }
}

// MARK: - Favorited Resources

extension UITestsRealmObjects {
    
    private static func getFavoritedResources() -> [RealmFavoritedResource] {
        return [
            Self.getFavoritedResource(resourceId: Self.fslTract, position: 0)
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
     
        return [getEnglishLanguage()]
    }
    
    private static func getEnglishLanguage() -> RealmLanguage {
        
        let object = RealmLanguage()
        
        object.code = "en"
        object.directionString = "ltr"
        object.id = "ui_test_language_1"
        object.name = "English"
        
        return object
    }
}

// MARK: - Translations

extension UITestsRealmObjects {
    
    static func getTranslations() -> [RealmTranslation] {
        
        return [
            getTMTSTranslation(),
            getFSLTranslation()
        ]
    }
    
    private static func getTMTSTranslation() -> RealmTranslation {
        
        let object = RealmTranslation()
        
        object.id = Self.tmtsEnTranslation
        object.isPublished = true
        object.manifestName = Self.tmtsManifest
        object.version = 1
        
        return object
    }
    
    private static func getFSLTranslation() -> RealmTranslation {
        
        let object = RealmTranslation()
        
        object.id = Self.fslEnTranslation
        object.isPublished = true
        object.manifestName = Self.fslManifest
        object.version = 1
        
        return object
    }
}
