//
//  HTMLDocument+ResourceUrls.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Fuzi

extension HTMLDocument {
    
    func getHTMLReferences(host: String, includeJavascript: Bool) -> [String] {
        
        var references: [String] = Array()
        references += xpath("//img[@src]").compactMap{ $0["src"] } // images
        references += xpath("//link[@rel='stylesheet'][@href]").compactMap{ $0["href"] } // css
        if includeJavascript {
            references += xpath("//script[@src]").compactMap{ $0["src"] } // javascript
        }
        
        return references.map { ref in
            if ref.hasPrefix("https") {
                return ref
            } else if ref.hasPrefix("//") {
                return "https:\(ref)"
            } else if ref.hasPrefix("/") {
                return "https://\(host)\(ref)"
            } else {
                return "https://\(host)/\(ref)"
            }
        }
    }
}
