//
//  AccountActivityViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol AccountActivityViewModelType {
    
    var localizationServices: LocalizationServices { get }
    var globalActivityResults: ObservableValue<GlobalActivityResults> { get }
    var alertMessage: ObservableValue<AlertMessageType?> { get }
}
