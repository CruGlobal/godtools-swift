//
//  FavoritedResourceDataModelInterface.swift
//  godtools
//
//  Created by Levi Eggert on 3/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol FavoritedResourceDataModelInterface {
    
    var createdAt: Date { get }
    var id: String { get }
    var position: Int { get }
}
