//
//  AccountViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol AccountViewModelType {
    
    var globalActivityServices: GlobalActivityServicesType { get }
    var navTitle: String { get }
    var items: [AccountItem] { get }
}
