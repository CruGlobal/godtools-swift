//
//  MockRepositorySyncDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct MockRepositorySyncDataModel {
    
    let id: String
    let name: String
    
    static func sortDataModelIds(dataModels: [MockRepositorySyncDataModel]) -> [String] {
        
        let sortedDataModels: [MockRepositorySyncDataModel] = dataModels.sorted {
            $0.id < $1.id
        }
        
        return sortedDataModels.map { $0.id }
    }
}
