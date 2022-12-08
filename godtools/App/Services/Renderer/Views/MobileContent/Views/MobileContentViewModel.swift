//
//  MobileContentViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentViewModel: NSObject {
    
    private let baseModel: BaseModel?
    private let baseModels: [BaseModel]
    
    init(baseModel: BaseModel?) {
        
        self.baseModel = baseModel
        
        if let baseModel = baseModel {
            self.baseModels = [baseModel]
        }
        else {
            self.baseModels = Array()
        }
                
        super.init()
    }
    
    init(baseModels: [BaseModel]) {
        
        self.baseModel = baseModels.first
        self.baseModels = baseModels
        
        super.init()
    }
}
