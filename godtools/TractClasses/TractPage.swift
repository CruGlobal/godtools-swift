//
//  TractPage.swift
//  godtools
//
//  Created by Pablo Marti on 6/1/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class TractPage: NSObject {
    
    var content: XMLIndexer?
    var pagination: TractPagination?
    
    init(withPageXML content: XMLIndexer) {
        self.content = content
    }
    
    func pageContent() -> XMLIndexer {
        return content!["page"]
    }
    
    func pageListeners() -> [String]? {
        var listeners = [String]()
        
        if pageContent().element?.attribute(by: "listeners") != nil {
            guard let listenersString = pageContent().element?.attribute(by: "listeners")!.text else {
                return listeners
            }
            
            for listener in listenersString.components(separatedBy: ",") {
                listeners.append(listener)
            }
        }
        
        return listeners
    }

}
