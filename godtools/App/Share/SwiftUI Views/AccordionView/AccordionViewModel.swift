//
//  AccordionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 9/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AccordionViewModel: ObservableObject {
    
    let sectionTitle: String = "Title Goes Here"
    let sectionContents: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    @Published var isExpanded: Bool = false
    
}
