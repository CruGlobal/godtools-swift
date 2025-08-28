//
//  MockRepositorySyncExternalDataFetch.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import RequestOperation

class MockRepositorySyncExternalDataFetch: RepositorySyncExternalDataFetchInterface {
        
    private static let delayRequestSeconds: TimeInterval = 1
    
    private let objects: [MockRepositorySyncDataModel]
    
    init(objects: [MockRepositorySyncDataModel]) {
        
        self.objects = objects
    }
    
    func getObjectPublisher(id: String, requestPriority: RequestPriority) -> AnyPublisher<RepositorySyncResponse<MockRepositorySyncDataModel>, Never> {
        
        return delayPublisher()
            .flatMap { _ -> AnyPublisher<RepositorySyncResponse<MockRepositorySyncDataModel>, Never> in
                
                let fetchedObjects: [MockRepositorySyncDataModel]
                
                if let existingObject = self.objects.first(where: {$0.id == id}) {
                    fetchedObjects = [existingObject]
                }
                else {
                    fetchedObjects = Array()
                }
                
                return Just(RepositorySyncResponse(objects: fetchedObjects, errors: []))
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getObjectsPublisher(requestPriority: RequestPriority) -> AnyPublisher<RepositorySyncResponse<MockRepositorySyncDataModel>, Never> {
        
        let allObjects: [MockRepositorySyncDataModel] = objects
        
        return delayPublisher()
            .flatMap { _ -> AnyPublisher<RepositorySyncResponse<MockRepositorySyncDataModel>, Never> in
                return Just(RepositorySyncResponse(objects: allObjects, errors: []))
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func delayPublisher() -> AnyPublisher<Void, Never> {
        
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.delayRequestSeconds) {
                promise(.success(Void()))
            }
        }
        .eraseToAnyPublisher()
    }
}
