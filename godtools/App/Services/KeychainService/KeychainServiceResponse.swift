//
//  KeychainServiceResponse.swift
//  godtools
//
//  Created by Rachael Skeath on 11/4/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum KeychainServiceResponse {
    case success
    case duplicateItem
    case unhandledError(NSError)
    
    init(osStatus: OSStatus) {
        
        if osStatus == errSecSuccess {
            self = .success
            
        } else if osStatus == errSecDuplicateItem {
            self = .duplicateItem
            
        } else {
            
            let error = NSError(domain: NSOSStatusErrorDomain, code: Int(osStatus))
            self = .unhandledError(error)
        }
    }
}
