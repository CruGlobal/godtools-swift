//
//  ResourcesDataType.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ResourcesDataType: Codable {
    
    associatedtype ResourcesList: Sequence
    
    var data: ResourcesList { get }
}
