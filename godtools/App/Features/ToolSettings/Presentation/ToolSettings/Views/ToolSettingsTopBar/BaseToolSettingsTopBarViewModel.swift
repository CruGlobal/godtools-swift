//
//  BaseToolSettingsTopBarViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class BaseToolSettingsTopBarViewModel: ObservableObject {
    
    @Published var title: String = ""
    
    init() {}
    
    func closeTapped() {}
}
