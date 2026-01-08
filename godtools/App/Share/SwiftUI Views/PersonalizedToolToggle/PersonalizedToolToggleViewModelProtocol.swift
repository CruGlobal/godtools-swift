//
//  PersonalizedToolToggleViewModelProtocol.swift
//  godtools
//
//  Created by Rachael Skeath on 12/18/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI
import Combine

protocol PersonalizedToolToggleViewModelProtocol: ObservableObject {
    
    var selectedIndexForToggle: Int { get set }
    var toggleItems: [String] { get }
}
