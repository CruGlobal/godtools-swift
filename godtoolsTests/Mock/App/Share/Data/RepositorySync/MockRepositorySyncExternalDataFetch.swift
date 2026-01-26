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

class MockRepositorySyncExternalDataFetch: GTRepositorySyncExternalDataFetchInterface {
            
    private let objects: [MockRepositorySyncDataModel]
    private let delayRequestSeconds: TimeInterval
    
    init(objects: [MockRepositorySyncDataModel], delayRequestSeconds: TimeInterval) {
        
        self.objects = objects
        self.delayRequestSeconds = delayRequestSeconds
    }
    
    func getObjectPublisher(id: String, requestPriority: RequestPriority) -> AnyPublisher<GTRepositorySyncResponse<MockRepositorySyncDataModel>, Never> {
        
        return delayPublisher()
            .flatMap { _ -> AnyPublisher<GTRepositorySyncResponse<MockRepositorySyncDataModel>, Never> in
                
                let fetchedObjects: [MockRepositorySyncDataModel]
                
                if let existingObject = self.objects.first(where: {$0.id == id}) {
                    fetchedObjects = [existingObject]
                }
                else {
                    fetchedObjects = Array()
                }
                
                return Just(GTRepositorySyncResponse(objects: fetchedObjects, errors: []))
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getObjectsPublisher(requestPriority: RequestPriority) -> AnyPublisher<GTRepositorySyncResponse<MockRepositorySyncDataModel>, Never> {
        
        let allObjects: [MockRepositorySyncDataModel] = objects
        
        return delayPublisher()
            .flatMap { _ -> AnyPublisher<GTRepositorySyncResponse<MockRepositorySyncDataModel>, Never> in
                return Just(GTRepositorySyncResponse(objects: allObjects, errors: []))
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func delayPublisher() -> AnyPublisher<Void, Never> {
        
        let delayRequestSeconds: TimeInterval = self.delayRequestSeconds
        
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + delayRequestSeconds) {
                promise(.success(Void()))
            }
        }
        .eraseToAnyPublisher()
    }
}
