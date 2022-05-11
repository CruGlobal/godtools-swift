//
//  ResourceModelType.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ResourceModelType {
    
    associatedtype TranslationIds = Sequence
    associatedtype AttachmentIds = Sequence
    
    var abbreviation: String { get }
    var attrAboutBannerAnimation: String { get }
    var attrAboutOverviewVideoYoutube: String { get }
    var attrBanner: String { get }
    var attrBannerAbout: String { get }
    var attrCategory: String { get }
    var attrDefaultOrder: Int { get }
    var id: String { get }
    var manifest: String { get }
    var name: String { get }
    var oneskyProjectId: Int { get }
    var resourceDescription: String { get }
    var resourceType: String { get }
    var totalViews: Int { get }
    var type: String { get }
    
    var latestTranslationIds: TranslationIds { get }
    var attachmentIds: AttachmentIds { get }
}
