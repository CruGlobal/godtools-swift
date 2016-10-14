//
//  MetaResponseHandler.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/14/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation

class MetaResponseHandler: NSObject {
    
    func parse(data: Any) {
        debugPrint(data)
        var json = data as! Dictionary<AnyHashable, String>
        
//        for (key, value) in data {
//            
//        }
    }
    
}
