//
//  ToolDetailControl.swift
//  godtools
//
//  Created by Levi Eggert on 6/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ToolDetailControl: GTSegmentType {
    
    let id: String
    let title: String
    let controlId: ToolDetailControlId
}

extension ToolDetailControl: Equatable {
    static func ==(lhs: ToolDetailControl, rhs: ToolDetailControl) -> Bool {
        return lhs.id == rhs.id
    }
}
