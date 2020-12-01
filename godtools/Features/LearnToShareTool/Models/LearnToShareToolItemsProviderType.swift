//
//  LearnToShareToolItemsProviderType.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol LearnToShareToolItemsProviderType {
    
    var learnToShareToolItems: ObservableValue<[LearnToShareToolItem]> { get }
}
