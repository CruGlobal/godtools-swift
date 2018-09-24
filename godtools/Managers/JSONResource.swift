//
//  File.swift
//  godtools
//
//  Created by Ryan Carlson on 9/21/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import Foundation
import SwiftyJSON

@objc protocol JSONResource {
    init()
    func type() -> String
    func attributeMappings() -> [String: String]
    func includedObjectMappings() -> [String: JSONResource.Type]
    func setValue(_ value: Any?, forKey key: String)
    
    @objc optional func relatedAttributeMapping() -> [String: String]
}

class JSONResourceFactory {
    
    static func initializeArrayFrom<T: JSONResource>(data: Data, type: T.Type) -> [T] {
        guard let json = try? JSON(data: data) else { return [T]() }
        
        return initializeArrayFrom(json: json, type: type)
    }
    
    private static func initializeArrayFrom<T: JSONResource>(json: JSON, type: T.Type) -> [T] {
        var resources = [T]()
        
        guard let jsonArray = json["data"].array else {
            return resources
        }
        
        for jsonResource in jsonArray {
            let resource = type.init()
            
            setAttributes(on: resource, from: jsonResource)
            setRelatedAttributes(on: resource, from: jsonResource)

            for (includedAttribute, includedType) in resource.includedObjectMappings() {
                let includedResources = JSONResourceFactory.initializeIncludedResourcesFrom(json: json["included"],
                                                                                type: includedType,
                                                                                parentType: T.self,
                                                                                parentResourceId: jsonResource["id"].stringValue)
                
                resource.setValue(includedResources, forKey: includedAttribute)
            }
            
            resources.append(resource)
            
        }
        return resources
    }
    
    private static func setAttributes(on resource: JSONResource, from json: JSON) {
        let resourceId = json["id"].stringValue
        
        resource.setValue(resourceId, forKey: "id")
        
        let attributeMappings = resource.attributeMappings()
        let jsonAttributes = json["attributes"]
        
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
    }
    
    private static func setRelatedAttributes(on resource: JSONResource, from json: JSON) {
        if let relatedAttributeMappingsFunction = resource.relatedAttributeMapping {
            let relatedAttributeMappings = relatedAttributeMappingsFunction()
            
            let jsonRelationships = jsonResource["relationships"]
            
            for attributeKey in relatedAttributeMappings.keys {
                if jsonRelationships[attributeKey]["data"]["id"].rawValue is String,
                    let attributeValue = jsonRelationships[attributeKey]["data"]["id"].string,
                    let objectKey = relatedAttributeMappings[attributeKey] {
                    resource.setValue(attributeValue, forKey: objectKey)
                } else if jsonRelationships[attributeKey]["data"]["id"].rawValue is NSNumber,
                    let attributeValue = jsonRelationships[attributeKey]["data"]["id"].number,
                    let objectKey = relatedAttributeMappings[attributeKey] {
                    resource.setValue(attributeValue, forKey: objectKey)
                } else {
                    debugPrint("unknown type for \(attributeKey)")
                }
            }
        }
    }
    
    private static func initializeIncludedResourcesFrom(json: JSON,
                                                        type: JSONResource.Type,
                                                        parentType: JSONResource.Type,
                                                        parentResourceId: String) -> [JSONResource] {
        var resources = [JSONResource]()
        
        guard let jsonArray = json.array else {
            return resources
        }
        
        for jsonResource in jsonArray {
            let resource = type.init()
            
            // since we are deserializing included objects, we need to do some additional checks:
            // 1) ensure the included object is the correct type of object we're looking for AND
            // 2) ensure that the included object is related to parent resource by matching IDs
            let parentResourceType = parentType.init().type()
            guard let relatedObjectParentId = jsonResource["relationships"][parentResourceType]["data"]["id"].string else { continue }
            guard let jsonResourceType = jsonResource["type"].string else { continue }
            let desiredType = resource.type()
            
            if jsonResourceType != desiredType || relatedObjectParentId != parentResourceId {
                continue
            }
            
            setAttributes(on: resource, from: jsonResource)
            setRelatedAttributes(on: resource, from: jsonResource)
            
            resources.append(resource)
        }
        
        return resources
    }
}
