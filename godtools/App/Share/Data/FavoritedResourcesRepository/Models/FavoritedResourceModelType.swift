//
//  FavoritedResourceModelType.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol FavoritedResourceModelType {
    
    var createdAt: Date { get }
    var resourceId: String { get }
}
