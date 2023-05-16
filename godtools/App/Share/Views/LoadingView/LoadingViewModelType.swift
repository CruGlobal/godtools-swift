//
//  LoadingViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol LoadingViewModelType {
    
    var message: ObservableValue<String> { get }
    var hidesCloseButton: Bool { get }
    
    func closeTapped()
    func pageViewed()
}

