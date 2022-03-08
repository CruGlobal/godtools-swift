//
//  NSError+Error.swift
//  godtools
//
//  Created by Levi Eggert on 2/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

extension NSError {
    
    static func errorWithDescription(description: String) -> Error {
        
        return NSError.errorWithDomain(domain: "", code: 0, description: description)
    }
    
    static func errorWithDomain(domain: String, code: Int, description: String) -> Error {
        
        return NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}
