//
//  HTMLDocumentWrapper.swift
//  godtools
//
//  Created by Levi Eggert on 1/7/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Fuzi
import libxml2

// NOTE:  Wrapper for addressing bad access starting in Xcode 16.2 Fuzi version 3.1.3. (https://github.com/cezheng/Fuzi/issues/130)
// Will fix by implementing change from open PR (https://github.com/cezheng/Fuzi/pull/131).
// TODO: GT-2492 Once merged we can remove this wrapper. ~Levi

class HTMLDocumentWrapper {
    
    let htmlDocument: HTMLDocument
    
    init(string: String, encoding: String.Encoding = String.Encoding.utf8) throws {
                
        guard let cChars = string.cString(using: encoding) else {
            throw XMLError.invalidData
        }
        
        let mutablebuffer = UnsafeMutableBufferPointer<CChar>.allocate(capacity: cChars.count)
        _ = mutablebuffer.initialize(from: cChars)
        
        defer {
            mutablebuffer.deallocate()
        }

        let buffer = UnsafeBufferPointer(mutablebuffer)

        let htmlDocument = try HTMLDocument(buffer: buffer)
        
        self.htmlDocument = htmlDocument
    }
}
