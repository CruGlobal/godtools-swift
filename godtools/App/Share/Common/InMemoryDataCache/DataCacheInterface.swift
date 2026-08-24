//
//  DataCacheInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol DataCacheInterface: Sendable {
    
    func cacheData(id: String, data: Data)
    func getData(id: String) -> Data?
}
