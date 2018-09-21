//
//  File.swift
//  godtools
//
//  Created by Ryan Carlson on 9/21/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import Foundation
import SwiftyJSON

class JSONResource: NSObject {
    
    override required init() {
        super.init()
    }
    
    func attributeMappings() -> [String: String] {
        return [String: String]()
    }
}

class JSONResourceFactory {
    static func initializeArrayFrom<T: JSONResource>(data: Data, type: T.Type) -> [T] {
        var resources = [T]()
        
        guard let json = try? JSON(data: data)["data"] else { return resources }
        
        for jsonResource in json.arrayValue {
            let resource = T()
            
            if let id = jsonResource["id"].string {
                resource.setValue(id, forKey: "id")
            }
            
            let attributeMappings = resource.attributeMappings()
            let jsonAttributes = jsonResource["attributes"]
            
            for attributeKey in attributeMappings.keys {
                if jsonAttributes[attributeKey].rawValue is String,
                    let attributeValue = jsonAttributes[attributeKey].string,
                    let objectKey = attributeMappings[attributeKey] {
                    resource.setValue(attributeValue, forKey: objectKey)
                } else if jsonAttributes[attributeKey].rawValue is NSNumber,
                    let attributeValue = jsonAttributes[attributeKey].number,
                    let objectKey = attributeMappings[attributeKey] {
                    resource.setValue(attributeValue, forKey: objectKey)
                } else {
                    debugPrint("unknown type for \(attributeKey)")
                }
            }
            
            resources.append(resource)
        }
        
        return resources
    }
}
