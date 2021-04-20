//
//  FavoritingToolMessageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol FavoritingToolMessageViewModelType {
    
    var message: String { get }
    var hidesMessage: ObservableValue<AnimatableValue<Bool>> { get }
    
    func closeTapped()
}
