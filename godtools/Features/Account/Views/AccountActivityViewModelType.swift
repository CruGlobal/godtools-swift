//
//  AccountActivityViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol AccountActivityViewModelType {
    
    var globalActivityResults: ObservableValue<GlobalActivityResults> { get }
    var alertMessage: ObservableValue<AlertMessage?> { get }
}
