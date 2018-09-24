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
    
    func setValue(_ value: Any?, forKey key: String)
    
    @objc optional func attributeMappings() -> [String: String]
    @objc optional func relatedAttributeMapping() -> [String: String]
    @objc optional func includedObjectMappings() -> [String: JSONResource.Type]

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
            
            guard let includedObjectMappingsFunction = resource.includedObjectMappings else { continue }
            
            for (includedAttribute, includedType) in includedObjectMappingsFunction() {
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
        
        let jsonAttributes = json["attributes"]
        
        for property in Mirror(reflecting: resource).children {
            guard let propertyName = property.label else { continue }
            if jsonAttributes[propertyName].rawValue is String,
                let attributeValue = jsonAttributes[propertyName].string {
                resource.setValue(attributeValue, forKey: propertyName)
            } else if jsonAttributes[propertyName].rawValue is NSNumber,
                let attributeValue = jsonAttributes[propertyName].number {
                resource.setValue(attributeValue, forKey: propertyName)
            }
        }
        
        guard let attributesMappingFunction = resource.attributeMappings else {
            return
        }
        
        let attributeMappings = attributesMappingFunction()

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
            
            let jsonRelationships = json["relationships"]
            
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
        
        let desiredIncludedResourceType: String = type.init().type()
        let parentResourceType: String = parentType.init().type()

        for jsonResource in jsonArray {
            let resource = type.init()
            
            // since we are deserializing included objects, we need to do some additional checks:
            // 1) ensure the included object is the correct type of object we're looking for AND
            // 2) ensure that the included object is related to parent resource by matching IDs
            guard let includedObjectParentId = jsonResource["relationships"][parentResourceType]["data"]["id"].string else { continue }
            guard let actualIncludedObjectType: String = jsonResource["type"].string else { continue }
            
            if actualIncludedObjectType != desiredIncludedResourceType || includedObjectParentId != parentResourceId {
                continue
            }
            
            setAttributes(on: resource, from: jsonResource)
            setRelatedAttributes(on: resource, from: jsonResource)
            
            resources.append(resource)
        }
        
        return resources
    }
}
