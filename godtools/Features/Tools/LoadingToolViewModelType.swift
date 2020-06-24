//
//  LoadingToolViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol LoadingToolViewModelType {
    
    var isLoading: ObservableValue<Bool> { get }
    var downloadProgress: ObservableValue<Double> { get }
    var progressValue: ObservableValue<String> { get }
    var alertMessage: ObservableValue<AlertMessageType?> { get }
    
    func closeTapped()
}
