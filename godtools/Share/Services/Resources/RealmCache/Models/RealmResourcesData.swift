//
//  RealmResourcesData.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmResourcesData: Object, ResourcesDataType {
    
    @objc dynamic var id: String = "shared"
    let data = List<RealmResource>()
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tools = try container.decode([RealmResource].self, forKey: .data)
        data.append(objectsIn: tools)
        
        super.init()
    }
    
    required init() {
        super.init()
    }
}
