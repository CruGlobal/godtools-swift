//
//  JsonServices.swift
//  godtools
//
//  Created by Levi Eggert on 2/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct JsonServices: JsonServicesType {
    
    private let bundle: Bundle
    
    init(bundle: Bundle = Bundle.main) {
        self.bundle = bundle
    }
    
    func getJsonData(fileName: String?) -> Data? {
        
        let result: Result<Data?, Error> = getJsonData(fileName: fileName)
        
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            assertionFailure(error.localizedDescription)
            return nil
        }
    }
    
    func getJsonData(fileName: String?) -> Result<Data?, Error> {
        
        if let filePath = bundle.path(forResource: fileName, ofType: "json") {
            let url: URL = URL(fileURLWithPath: filePath)
            do {
                let data: Data = try Data(contentsOf: url, options: [])
                return .success(data)
            }
            catch let error {
                return .failure(error)
            }
        }
        else {
            let error = NSError(domain: "JsonServices", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to locate json file at :\(String(describing: fileName))"])
            return .failure(error)
        }
    }
    
    func getJsonData(json: Any?, options: JSONSerialization.WritingOptions = []) -> Data? {
        
        let result: Result<Data?, Error> = getJsonData(json: json, options: options)
        
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            assertionFailure(error.localizedDescription)
            return nil
        }
    }
    
    func getJsonData(json: Any?, options: JSONSerialization.WritingOptions = []) -> Result<Data?, Error> {
        
        guard let json = json else {
            return .success(nil)
        }
        
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: json, options: options)
            return .success(jsonData)
        }
        catch let error {
            return .failure(error)
        }
    }
    
    func getJsonObject(data: Data?, options: JSONSerialization.ReadingOptions = []) -> Any? {
        
        let result: Result<Any?, Error> = getJsonObject(data: data, options: options)
        
        switch result {
        case .success(let jsonObject):
            return jsonObject
        case .failure(let error):
            assertionFailure(error.localizedDescription)
            return nil
        }
    }
    
    func getJsonObject(data: Data?, options: JSONSerialization.ReadingOptions = []) -> Result<Any?, Error> {
        
        guard let data = data else {
            return .success(nil)
        }
        
        do {
            let jsonObject: Any = try JSONSerialization.jsonObject(with: data, options: options)
            return .success(jsonObject)
        }
        catch let error {
            return .failure(error)
        }
    }
    
    func getJsonString(json: Any?, options: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions(rawValue: 0)) -> String {
        
        let result: Result<String, Error> = getJsonString(json: json, options: options)
        
        switch result {
        case .success(let jsonString):
            return jsonString
        case .failure(let error):
            assertionFailure(error.localizedDescription)
            return ""
        }
    }
    
    func getJsonString(json: Any?, options: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions(rawValue: 0)) -> Result<String, Error> {
        
        guard let json = json else {
            return .success("")
        }
        
        do {
            let data: Data = try JSONSerialization.data(withJSONObject: json, options: options)
            let jsonString: String? = String(data: data, encoding: .utf8)
            return .success(jsonString ?? "")
        }
        catch let error {
            return .failure(error)
        }
    }
    
    // MARK: - Decoding
    
    func decodeArray<T>(fileName: String?) -> [T] where T : Decodable {
        
        let result: Result<[T], Error> = decodeArray(fileName: fileName)
        
        switch result {
        case .success(let array):
            return array
        case .failure(let error):
            assertionFailure(error.localizedDescription)
            return []
        }
    }
    
    func decodeArray<T>(fileName: String?) -> Result<[T], Error> where T : Decodable {
        
        let dataResult: Result = getJsonData(fileName: fileName)
        
        switch dataResult {
        case .success(let data):
            
            let arrayResult: Result<[T], Error> = decodeArray(data: data)
            
            switch arrayResult {
            case .success(let array):
                return .success(array)
            case .failure(let error):
                return .failure(error)
            }
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func decodeArray<T>(data: Data?) -> [T] where T : Decodable {
        
        let result: Result<[T], Error> = decodeArray(data: data)
        
        switch result {
        case .success(let array):
            return array
        case .failure(let error):
            assertionFailure(error.localizedDescription)
            return []
        }
    }
    
    func decodeArray<T>(data: Data?) -> Result<[T], Error> where T : Decodable {
        
        guard let data = data else {
            return .success([])
        }
        
        do {
            let array: [T] = try JSONDecoder().decode([T].self, from: data)
            return .success(array)
        }
        catch let error {
            return .failure(error)
        }
    }
    
    func decodeObject<T>(data: Data?) -> T? where T : Decodable {
        
        let result: Result<T?, Error> = decodeObject(data: data)
        
        switch result {
        case .success(let object):
            return object
        case .failure(let error):
            assertionFailure(error.localizedDescription)
            return nil
        }
    }
    
    func decodeObject<T>(data: Data?) -> Result<T?, Error> where T : Decodable {
        
        guard let data = data else {
            return .success(nil)
        }
        
        do {
            let object: T? = try JSONDecoder().decode(T.self, from: data)
            return .success(object)
        }
        catch let error {
            return .failure(error)
        }
    }
    
    func decodeJsonObject<T>(jsonObject: [String: Any], options: JSONSerialization.WritingOptions = []) -> T? where T : Decodable {
          
        let result: Result<T?, Error> = decodeJsonObject(jsonObject: jsonObject, options: options)
        
        switch result {
        case .success(let object):
            return object
        case .failure(let error):
            assertionFailure(error.localizedDescription)
            return nil
        }
    }
    
    func decodeJsonObject<T>(jsonObject: [String: Any], options: JSONSerialization.WritingOptions = []) -> Result<T?, Error> where T : Decodable {
                
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: jsonObject, options: options)
            return decodeObject(data: jsonData)
        }
        catch let error {
            return .failure(error)
        }
    }
    
    // MARK: - Encoding
    
    func encode<T>(object: T, options: JSONSerialization.ReadingOptions = []) -> [String : Any] where T : Encodable {
        
        let result: Result<[String : Any], Error> = encode(object: object, options: options)
        
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            assertionFailure(error.localizedDescription)
            return Dictionary()
        }
    }
    
    func encode<T>(object: T, options: JSONSerialization.ReadingOptions = []) -> Result<[String : Any], Error> where T : Encodable {
                
        do {
            
            let data: Data? = try JSONEncoder().encode(object)
            
            if let data = data {
                do {
                    let json: [String: Any]? = try JSONSerialization.jsonObject(
                        with: data,
                        options: options
                    ) as? [String: Any]
                    
                    return .success(json ?? [:])
                }
                catch let error {
                    return .failure(error)
                }
            }
        }
        catch let error {
            return .failure(error)
        }
        
        return .success([:])
    }
}
