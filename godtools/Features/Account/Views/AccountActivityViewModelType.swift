//
//  AccountActivityViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol AccountActivityViewModelType {
    
    var globalActivityAttributes: ObservableValue<[GlobalActivityAttribute]> { get }
    var isLoadingGlobalActivity: ObservableValue<Bool> { get }
    var didFailToGetGlobalActivity: ObservableValue<Bool> { get }
}
