//
//  Config.swift
//  godtools
//
//  Created by Michael Harrison on 5/23/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import CRUConfig

class Config: CRUEmptyConfig {
    @objc var baseUrl: URL? = nil
    @objc var apiKey: String = ""
    @objc var googleAnalyticsApiKey: String = ""
    @objc var googleAdwordsConversionId: String = ""
    @objc var googleAdwordsLabel: String = ""
}
