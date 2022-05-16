//
//  BaseToolSettingsOptionsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

class BaseToolSettingsOptionsViewModel: ObservableObject {
    
    @Published var trainingTipsIcon: Image = Image("")
    @Published var trainingTipsTitle: String = ""
    
    init() {}
    
    func shareLinkTapped() {}
    func screenShareTapped() {}
    func trainingTipsTapped() {}
}
