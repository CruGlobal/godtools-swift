//
//  ScriptJsonApiResponseDataObject.swift
//  request-operation-ios
//
//  Created by Levi Eggert on 5/29/2024.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

// NOTE: This is copied from RequestOperation/Codable/JsonApi/JsonApiResponseDataObject.swift.
// And is required for build phases script DownloadInitialResources ResourceModel.swift.
// I had to remove the request-operation dependency from ResourceModel.swift because I couldn't figure out how to use external dependencies when running a script. ~Levi

public struct ScriptJsonApiResponseDataObject<T: Codable>: Codable {
    
    public let dataObject: T
    
    public enum CodingKeys: String, CodingKey {
        case dataObject = "data"
    }
}
