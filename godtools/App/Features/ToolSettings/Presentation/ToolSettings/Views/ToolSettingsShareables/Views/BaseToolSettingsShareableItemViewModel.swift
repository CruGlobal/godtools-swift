//
//  BaseToolSettingsShareableItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

class BaseToolSettingsShareableItemViewModel: ObservableObject {
    
    @Published var image: Image = Image("")
    @Published var title: String = ""
    
    init() {}
}
