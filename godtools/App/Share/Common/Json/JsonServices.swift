//
//  JsonServices.swift
//  godtools
//
//  Created by Levi Eggert on 2/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct JsonServices {
    
    private let bundle: Bundle
    
    init(bundle: Bundle = Bundle.main) {
        self.bundle = bundle
    }
    
    func getJsonData(fileName: String) throws -> Data {
        
        guard let filePath = bundle.path(forResource: fileName, ofType: "json") else {
            let error = NSError(domain: "JsonServices", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to locate json file at :\(String(describing: fileName))"])
            throw error
        }
        
        let url: URL = URL(fileURLWithPath: filePath)
        
        return try Data(contentsOf: url, options: [])
    }
    
    func getJsonData(json: Any, options: JSONSerialization.WritingOptions = []) throws -> Data {
        
        return try JSONSerialization.data(withJSONObject: json, options: options)
    }
    
    func getJsonObject(data: Data, options: JSONSerialization.ReadingOptions = []) throws -> Any {
        
        return try JSONSerialization.jsonObject(with: data, options: options)
    }
    
    func getJsonString(json: Any, options: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions(rawValue: 0)) throws -> String? {
        
        let data: Data = try JSONSerialization.data(withJSONObject: json, options: options)
        let jsonString: String? = String(data: data, encoding: .utf8)
        
        return jsonString
    }
}

// MARK: - Decoding

extension JsonServices {
    
    func decodeArray<T>(fileName: String) throws -> [T] where T: Decodable {
        
        let data: Data = try getJsonData(fileName: fileName)
        
        return try decodeArray(data: data)
    }
    
    func decodeArray<T>(data: Data) throws -> [T] where T: Decodable {
        
        return try JSONDecoder().decode([T].self, from: data)
    }
    
    func decodeObject<T>(data: Data) throws -> T where T: Decodable {
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func decodeJsonObject<T>(jsonObject: [String: Any], options: JSONSerialization.WritingOptions = []) throws -> T where T: Decodable {
                
        return try decodeObject(
            data: try JSONSerialization.data(withJSONObject: jsonObject, options: options)
        )
    }
}

// MARK: - Encoding

extension JsonServices {
    
    func encode<T>(object: T, options: JSONSerialization.ReadingOptions = []) throws -> [String: Any] where T: Encodable {
        
        let data: Data = try JSONEncoder().encode(object)
        
        let json: [String: Any]? = try JSONSerialization.jsonObject(
            with: data,
            options: options
        ) as? [String: Any]
        
        return json ?? [:]
    }
}
