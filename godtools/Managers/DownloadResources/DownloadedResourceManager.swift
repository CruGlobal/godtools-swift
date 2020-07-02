//
//  DownloadedResourceManager.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import PromiseKit
import RealmSwift

class DownloadedResourceManager: GTDataManager {    
    
    override func buildURL() -> URL? {
        
        let baseUrl: String = AppConfig().mobileContentApiBaseUrl
        let path: String = "/resources"
        return URL(string: baseUrl + path)
    }
}
