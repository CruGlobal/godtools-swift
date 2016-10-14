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

        for(language) in (data as! NSDictionary).value(forKey: "languages") as! NSArray {
            let languageDictionary = language as! NSDictionary
            let name:String = languageDictionary.value(forKey: "name") as! String
            let code:String = languageDictionary.value(forKey: "code") as! String
            debugPrint("Language code: \(code) name: \(name)")
        }
    }
}
