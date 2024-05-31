//
//  StoreInitialFavoritedToolsInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/24/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol StoreInitialFavoritedToolsInterface {
    
    func storeInitialFavoritedToolsPublisher() -> AnyPublisher<Void, Never>
}
