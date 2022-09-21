//
//  BaseLanguagesListItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class BaseLanguagesListItemViewModel: ObservableObject {
    
    @Published var name: String = ""
    @Published var isSelected: Bool = false
}
