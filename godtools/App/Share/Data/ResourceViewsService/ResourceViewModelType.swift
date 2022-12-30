//
//  ResourceViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 6/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ResourceViewModelType {
    
    var resourceId: String { get }
    var quantity: Int { get }
}
