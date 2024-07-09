//
//  AppLanguagesRepositorySyncInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol AppLanguagesRepositorySyncInterface {
    
    func syncPublisher() -> AnyPublisher<Void, Never>
}
