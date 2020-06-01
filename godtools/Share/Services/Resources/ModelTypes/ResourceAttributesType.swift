//
//  ResourceAttributesType.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ResourceAttributesType: Codable {
    
    var name: String? { get }
    var abbreviation: String? { get }
    var toolDescription: String? { get }
    var oneskyProjectId: Int? { get }
    var totalViews: Int? { get }
    var manifest: String? { get }
    var resourceType: String? { get }
    var attrBanner: String? { get }
    var attrBannerAbout: String? { get }
}
