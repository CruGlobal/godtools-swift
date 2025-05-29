//
//  IgnoreCacheSession.swift
//  godtools
//
//  Created by Levi Eggert on 6/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class IgnoreCacheSession {
        
    let session: URLSession
    
    init() {
        
        session = URLSession(
            configuration: CreateIgnoreCacheSessionConfig().createConfiguration()
        )
    }
}
