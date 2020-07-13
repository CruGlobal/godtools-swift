//
//  AlertMessageType.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol AlertMessageType {
    
    var title: String { get }
    var message: String { get }
}
