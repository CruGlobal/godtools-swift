//
//  SwiftUIPreviewDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 8/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class SwiftUIPreviewDatabase: RealmDatabase {
    
    init() {
        
        super.init(databaseConfiguration: SwiftUIPreviewDatabaseConfiguration(), realmInstanceCreationType: .usesASingleSharedRealmInstance)
        
        let objects: [Object] = getResources() + getLanguages()
        
        let realm: Realm = super.openRealm()
        
        do {
            
            try realm.write {
                realm.add(objects)
            }
        }
        catch let error {
            
            assertionFailure("Failed to add objects to swiftui preview realm.\n  error: \(error)")
        }
    }
    
    private func getResources() -> [RealmResource] {
        
        return [
            Self.getKgpTool(),
            Self.getTeachMeToShareTool(),
            Self.getFourSpiritualLawsTool()
        ]
    }
    
    private func getLanguages() -> [RealmLanguage] {
     
        let english = RealmLanguage()
        
        english.code = "en"
        english.directionString = "ltr"
        english.id = "1"
        english.name = "English"
        
        return [english]
    }
}

extension SwiftUIPreviewDatabase {
    
    private static func getKgpTool() -> RealmResource {
        
        let resource = RealmResource()
        
        resource.abbreviation = "kgp"
        resource.attrCategory = "gospel"
        resource.attrSpotlight = true
        resource.id = "1"
        resource.name = AccessibilityStrings.Button.ToolName.knowingGodPersonally.rawValue
        resource.resourceDescription = "A Gospel presentation that uses hand drawn images to help illustrate God's invitation to know Him personally. \n\nConversation starter: Has anyone ever shared with you how you can know God personally?\n\nAll Bible references are from the New Living Translation."
        resource.totalViews = 12579
        
        return resource
    }
    
    private static func getTeachMeToShareTool() -> RealmResource {
        
        let resource = RealmResource()
        
        resource.abbreviation = "teachmetoshare"
        resource.attrCategory = "training"
        resource.attrSpotlight = true
        resource.id = "8"
        resource.name = AccessibilityStrings.Button.ToolName.teachMeToShare.rawValue
        resource.resourceDescription = "Training tips on how to share your faith."
        resource.totalViews = 615670
        
        return resource
    }
    
    private static func getFourSpiritualLawsTool() -> RealmResource {
        
        let resource = RealmResource()
        
        resource.abbreviation = "fourlaws"
        resource.attrCategory = "gospel"
        resource.attrSpotlight = false
        resource.id = "4"
        resource.name = AccessibilityStrings.Button.ToolName.fourSpiritualLaws.rawValue
        resource.resourceDescription = "Classic gospel presentation of God's invitation to those who don't yet know him. \n\nConversation starter: I have a summary of the Bible's message using four simple ideas. May I share it with you?\n\nAll Bible references are from the New American Standard Bible unless otherwise stated."
        resource.totalViews = 2533146
        
        return resource
    }
}
