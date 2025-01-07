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

class HTMLDocumentWrapper {
    
    let htmlDocument: HTMLDocument
    
    init(string: String, encoding: String.Encoding = String.Encoding.utf8) throws {
        
        guard let cChars = string.cString(using: encoding) else {
            throw XMLError.invalidData
        }
        
        let buffer = cChars.withUnsafeBufferPointer { buffer in
            UnsafeBufferPointer(rebasing: buffer[0..<buffer.count])
        }
                
        // NOTE: Seems to solve bad access at line 130 in Document.swift Fuzi version 3.1.3. "guard let document = type(of: self).parse(buffer: buffer, options: options)" ~Levi
        let htmlDocument = try HTMLDocument(buffer: buffer)
        
        self.htmlDocument = htmlDocument
    }
}
