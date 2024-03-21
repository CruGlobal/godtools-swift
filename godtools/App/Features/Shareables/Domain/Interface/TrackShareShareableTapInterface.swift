//
//  TrackShareShareableTapInterface.swift
//  godtools
//
//  Created by Levi Eggert on 2/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol TrackShareShareableTapInterface {
    
    func trackShareShareableTapPublisher(toolId: String, shareableId: String) -> AnyPublisher<Void, Never>
}
