//
//  ConfigType.swift
//  godtools
//
//  Created by Levi Eggert on 2/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ConfigType {
    
    var build: AppBuild { get }
    var isDebug: Bool { get }
    var appleAppId: String { get }
    var versionLabel: String { get }
    var mobileContentApiBaseUrl: String { get }
    var appsFlyerDevKey: String { get }
    var googleAnalyticsApiKey: String { get }
    var googleAdwordsConversionId: String { get }
    var googleAdwordsLabel: String { get }
    var firebaseGoogleServiceFileName: String { get }
    
    func logConfiguration()
}
