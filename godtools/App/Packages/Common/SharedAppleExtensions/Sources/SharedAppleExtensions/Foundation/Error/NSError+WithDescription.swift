//
//  Error+WithDescription.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 2/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

public extension NSError {
    
    static func errorWithDescription(description: String) -> NSError {
        
        return NSError.errorWithDomain(domain: "", code: 0, description: description)
    }
    
    static func errorWithDomain(domain: String, code: Int, description: String) -> NSError {
        
        return NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}
