//
//  FileCache+Combine.swift
//  godtools
//
//  Created by Levi Eggert on 7/19/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

extension FileCache {
    
    func getFileExistsPublisher(location: FileCacheLocation) -> AnyPublisher<Bool, Error> {
        
        switch getFileExists(location: location) {
        case .success(let fileExists):
            return Just(fileExists).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    func getDataPublisher(location: FileCacheLocation) -> AnyPublisher<Data?, Error> {
        
        switch getData(location: location) {
        case .success(let data):
            return Just(data).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    func storeFilePublisher(location: FileCacheLocation, data: Data) -> AnyPublisher<URL, Error> {
        
        switch storeFile(location: location, data: data) {
        case .success(let url):
            return Just(url).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}
