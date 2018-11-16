//
//  XMLCategory.swift
//  godtools
//
//  Created by Igor Ostriz on 15/11/2018.
//  Copyright © 2018 Cru. All rights reserved.
//


import UIKit
import SWXMLHash


class XMLCategory: NSObject {

    var content: XMLIndexer?

    init(withXML content: XMLIndexer) {
        self.content = content
    }
    
    func label() -> String? {
        return content?["label"]["content:text"].element?.text
    }

    func banner() -> String? {
        return content?.value(ofAttribute: "banner")
    }

}
