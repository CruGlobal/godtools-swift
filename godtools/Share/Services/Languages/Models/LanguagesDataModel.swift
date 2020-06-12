//
//  LanguagesDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct LanguagesDataModel: Decodable {
    
    let data: [LanguageModel]
    
    enum RootKeys: String, CodingKey {
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        data = try container.decode([LanguageModel].self, forKey: .data)
    }
}
