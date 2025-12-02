//
//  MockResource.swift
//  godtools
//
//  Created by Levi Eggert on 11/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class MockResource: ResourceDataModelInterface {
    
    var abbreviation: String = ""
    var attrAboutBannerAnimation: String = ""
    var attrAboutOverviewVideoYoutube: String = ""
    var attrBanner: String = ""
    var attrBannerAbout: String = ""
    var attrCategory: String = ""
    var attrDefaultLocale: String = ""
    var attrDefaultOrder: Int = 0
    var attrSpotlight: Bool = false
    var defaultVariantId: String?
    var id: String = ""
    var isHidden: Bool = false
    var manifest: String = ""
    var metatoolId: String?
    var name: String = ""
    var oneskyProjectId: Int = 0
    var resourceDescription: String = ""
    var resourceType: String = ""
    var totalViews: Int = 0
    var type: String = ""
    
    static func createResource(resourceType: ResourceType, id: String = UUID().uuidString, attrDefaultLocale: String = "", attrCategory: String = "", attrSpotlight: Bool = false, isHidden: Bool = false) -> MockResource {
        
        let resource = MockResource()
        
        resource.attrCategory = attrCategory
        resource.attrDefaultLocale = attrDefaultLocale
        resource.attrSpotlight = attrSpotlight
        resource.id = id
        resource.isHidden = isHidden
        resource.resourceType = resourceType.rawValue
        
        return resource
    }
    
    func getAttachmentIds() -> [String] {
        return Array()
    }
    
    func getLanguageIds() -> [String] {
        return Array()
    }
    
    func getLatestTranslationIds() -> [String] {
        return Array()
    }
    
    func getVariantIds() -> [String] {
        return Array()
    }
}
