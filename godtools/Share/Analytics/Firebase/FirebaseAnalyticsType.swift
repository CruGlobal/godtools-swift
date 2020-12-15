//
//  FirebaseAnalyticsType.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol FirebaseAnalyticsType: MobileContentAnalyticsSystem {
    func configure()
    func trackScreenView(screenName: String, siteSection: String, siteSubSection: String)
    func trackAction(screenName: String?, actionName: String, data: [AnyHashable : Any]?)
    func trackExitLink(screenName: String, siteSection: String, siteSubSection: String, url: URL)
    func fetchAttributesThenSetUserId()
}
