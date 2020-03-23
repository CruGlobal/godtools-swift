//
//  ToolsLanguagePreferenceCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolsLanguagePreferenceCacheType {
    
    var primaryLanguageId: String? { get }
    var parallelLanguageId: String? { get }
    
    func cachePrimaryLanguageId(id: String)
    func cacheParallelLanguageId(id: String)
    func deletePrimaryLanguageId()
    func deleteParallelLanguageId()
}
