//
//  Data+ToSha256Hash.swift
//  godtools
//
//  Created by Levi Eggert on 5/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import CryptoKit

extension Data {
    
    func toSha256Hash() -> String {
        
        let sha256Hash: SHA256.Digest = SHA256.hash(data: self)
        let lowercaseSha256Hash: String = sha256Hash.compactMap { String(format: "%02x", $0) }.joined()
        
        return lowercaseSha256Hash
    }
}
