//
//  MultiplatformFlowWatcher.swift
//  godtools
//
//  Created by Levi Eggert on 9/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformFlowWatcher {
    
    private let flowWatcher: FlowWatcher
    
    required init(flowWatcher: FlowWatcher) {
        
        self.flowWatcher = flowWatcher
    }
    
    func close() {
        flowWatcher.close()
    }
}
