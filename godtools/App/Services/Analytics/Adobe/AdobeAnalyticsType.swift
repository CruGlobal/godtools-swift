//
//  AdobeAnalyticsType.swift
//  godtools
//
//  Created by Levi Eggert on 3/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol AdobeAnalyticsType: MobileContentAnalyticsSystem {
    
    var visitorMarketingCloudID: String { get }
    
    func configure()
    func collectLifecycleData()
    func trackScreenView(trackScreen: TrackScreenModel)
    func trackAction(trackAction: TrackActionModel)
    func trackExitLink(exitLink: ExitLinkModel)
    func fetchAttributesThenSyncIds()
}
