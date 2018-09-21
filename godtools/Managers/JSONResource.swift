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
    class var type: String {
        return "unknown"
    }
    
    override required init() {
        super.init()
    }
    
    func attributeMappings() -> [String: String] {
        return [String: String]()
    }
}

class JSONResourceFactory {
    
    static func initializeArrayFrom<T: JSONResource, U: JSONResource>(data: Data, type: T.Type, includedTypes: [T.Type]? = nil, parentType: U.Type? = nil, parentResourceId: String? = nil) -> [T] {
        guard let json = try? JSON(data: data)["data"] else { return [T]() }
        return initializeArrayFrom(json: json, type: type, includedTypes: includedTypes, parentType: parentType, parentResourceId: parentResourceId)
    }
    
    static func initializeArrayFrom<T: JSONResource, U: JSONResource>(json: JSON, type: T.Type, includedTypes: [T.Type]? = nil, parentType: U.Type? = nil, parentResourceId: String? = nil) -> [T] {
        var resources = [T]()
        
        guard let jsonArray = json.array else { return resources }
        
        for jsonResource in jsonArray {
            guard let resourceId = jsonResource["id"].string else { continue }
            
            // if there is a parent resource ID, that means we are deserializing included objects
            // we need to do some additional checks:
            // 1) ensure the included object is the correct type of object we're looking for AND
            // 2) ensure that the included object is related to parent resource by matching IDs
            if let parentResourceId = parentResourceId {
                guard let jsonResourceType = jsonResource["type"].string,
                    jsonResourceType == T.type,
                    jsonResource["relationships"][U.type]["data"]["id"].string == parentResourceId else { continue }
            }
            
            let resource = T()

            resource.setValue(resourceId, forKey: "id")
            
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
            
            guard let includedTypes = includedTypes else { continue }
            
            for includedType in includedTypes {
                let includedResources = JSONResourceFactory.initializeArrayFrom(json: json["included"], type: includedType, parentType: T.self, parentResourceId: resourceId)
            }
            
            resources.append(resource)
        }
        
        return resources
    }
}
