//
//  JsonServicesType.swift
//  godtools
//
//  Created by Levi Eggert on 2/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol JsonServicesType {
    
    func getJsonData(fileName: String?) -> Data?
    func getJsonData(fileName: String?) -> Result<Data?, Error>
    func getJsonData(json: Any?, options: JSONSerialization.WritingOptions) -> Data?
    func getJsonData(json: Any?, options: JSONSerialization.WritingOptions) -> Result<Data?, Error>
    func getJsonObject(data: Data?, options: JSONSerialization.ReadingOptions) -> Any?
    func getJsonObject(data: Data?, options: JSONSerialization.ReadingOptions) -> Result<Any?, Error>
    func getJsonString(json: Any?, options: JSONSerialization.WritingOptions) -> String
    func getJsonString(json: Any?, options: JSONSerialization.WritingOptions) -> Result<String, Error>
    func decodeArray<T: Decodable>(fileName: String?) -> [T]
    func decodeArray<T: Decodable>(fileName: String?) -> Result<[T], Error>
    func decodeArray<T: Decodable>(data: Data?) -> [T]
    func decodeArray<T: Decodable>(data: Data?) -> Result<[T], Error>
    func decodeObject<T: Decodable>(data: Data?) -> T?
    func decodeObject<T: Decodable>(data: Data?) -> Result<T?, Error>
    func encode<T: Encodable>(object: T, options: JSONSerialization.ReadingOptions) -> [String: Any]
    func encode<T: Encodable>(object: T, options: JSONSerialization.ReadingOptions) -> Result<[String: Any], Error>
}
