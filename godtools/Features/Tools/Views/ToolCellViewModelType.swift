//
//  ToolCellViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolCellViewModelType {
    
    var title: String { get }
    var description: String { get }
    var isFavorited: Bool { get }
}
