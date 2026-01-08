//
//  UITestsRealmObjects.swift
//  godtools
//
//  Created by Levi Eggert on 1/8/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

final class UITestsRealmObjects {
    
    init() {
        
    }
    
    func getResources() -> [RealmResource] {
        
        return [
            getKgpTool(),
            getTeachMeToShareTool(),
            getFourSpiritualLawsTool()
        ]
    }
    
    func getLanguages() -> [RealmLanguage] {
     
        let english = RealmLanguage()
        
        english.code = "en"
        english.directionString = "ltr"
        english.id = "ui_test_language_1"
        english.name = "English"
        
        return [english]
    }
    
    private func getKgpTool() -> RealmResource {
        
        let resource = RealmResource()
        
        resource.abbreviation = "kgp"
        resource.attrCategory = "gospel"
        resource.attrSpotlight = true
        resource.id = "ui_test_resource_1"
        resource.name = AccessibilityStrings.Button.ToolName.knowingGodPersonally.rawValue
        resource.resourceDescription = "A Gospel presentation that uses hand drawn images to help illustrate God's invitation to know Him personally. \n\nConversation starter: Has anyone ever shared with you how you can know God personally?\n\nAll Bible references are from the New Living Translation."
        resource.totalViews = 12579
        
        return resource
    }
    
    private func getTeachMeToShareTool() -> RealmResource {
        
        let resource = RealmResource()
        
        resource.abbreviation = "teachmetoshare"
        resource.attrCategory = "training"
        resource.attrSpotlight = true
        resource.id = "ui_test_resource_2"
        resource.name = AccessibilityStrings.Button.ToolName.teachMeToShare.rawValue
        resource.resourceDescription = "Training tips on how to share your faith."
        resource.totalViews = 615670
        
        return resource
    }
    
    private func getFourSpiritualLawsTool() -> RealmResource {
        
        let resource = RealmResource()
        
        resource.abbreviation = "fourlaws"
        resource.attrCategory = "gospel"
        resource.attrSpotlight = false
        resource.id = "ui_test_resource_3"
        resource.name = AccessibilityStrings.Button.ToolName.fourSpiritualLaws.rawValue
        resource.resourceDescription = "Classic gospel presentation of God's invitation to those who don't yet know him. \n\nConversation starter: I have a summary of the Bible's message using four simple ideas. May I share it with you?\n\nAll Bible references are from the New American Standard Bible unless otherwise stated."
        resource.totalViews = 2533146
        
        return resource
    }
}
