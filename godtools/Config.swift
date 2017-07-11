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
    var baseUrl: URL? = nil
    var apiKey: String = ""
    var googleAnalyticsApiKey: String = ""
    var googleAdwordsConversionId: String = ""
    var googleAdwordsLabel: String = ""
}
