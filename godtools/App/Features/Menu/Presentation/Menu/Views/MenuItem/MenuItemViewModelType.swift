//
//  MenuItemViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol MenuItemViewModelType {
    
    var title: String { get }
    var selectionDisabled: Bool { get }
}
