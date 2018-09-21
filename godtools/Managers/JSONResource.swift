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

    class var type: String {
        return "unknown"
    }
    
    class var attributeMappings: [String: String] {
        return [String: String]()
    }
    
    class var includedObjectMappings: [String: JSONResource.Type] {
        return [String: JSONResource.Type]()
    }
}

class JSONResourceFactory {
    
    static func initializeArrayFrom<T: JSONResource>(data: Data, type: T.Type) -> [T] {
        guard let json = try? JSON(data: data) else { return [T]() }
        
        return initializeArrayFrom(json: json, type: type, parentType: nil, parentResourceId: nil)
    }
    
    static func initializeArrayFrom<T: JSONResource, U: JSONResource>(json: JSON,
                                                                      type: T.Type,
                                                                      parentType: U.Type? = nil,
                                                                      parentResourceId: String? = nil) -> [T] {
        var resources = [T]()
        
        guard let jsonArray = (json.array != nil) ? json.arrayValue : ((json["data"].array != nil) ? json["data"].arrayValue : nil) else {
            return resources
        }

        for jsonResource in jsonArray {
            guard let resourceId = jsonResource["id"].string else { continue }
            let parentResourceType = U.type
            
            // if there is a parent resource ID, that means we are deserializing included objects
            // we need to do some additional checks:
            // 1) ensure the included object is the correct type of object we're looking for AND
            // 2) ensure that the included object is related to parent resource by matching IDs
            if let parentResourceId = parentResourceId {
                guard let relatedObjectParentId = jsonResource["relationships"][parentResourceType]["data"]["id"].string else { continue }
                guard let jsonResourceType = jsonResource["type"].string else { continue }
                let desiredType = T.type
                
                if jsonResourceType != desiredType || relatedObjectParentId == parentResourceId {
                        continue
                }
            }
            
            let resource = T()

            resource.setValue(resourceId, forKey: "id")
            
            let attributeMappings = T.attributeMappings
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
            
            for (includedAttribute, includedType) in T.includedObjectMappings {
                let includedResources = JSONResourceFactory.initializeArrayFrom(json: json["included"], type: includedType, parentType: T.self, parentResourceId: resourceId)

                let mirror = Mirror(reflecting: resource)
                
                guard let includedField = mirror.children.filter({ (child) -> Bool in
                    child.label != nil && child.label! == includedAttribute
                }).first else { continue }
                
                debugPrint("\(includedField) type: \(includedField.value)")
                if includedField.value is Array<Any> {
                    resource.setValue(includedResources, forKey: includedAttribute)
                } else if let includedResource = includedResources.first {
                    resource.setValue(includedResource, forKey: includedAttribute)
                } else {
                    debugPrint("unable to set included resource for \(includedAttribute)")
                }

            }
            
            resources.append(resource)
        }
        
        return resources
    }
}
