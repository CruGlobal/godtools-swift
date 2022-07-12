//
//  AboutTextCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AboutTextCellViewModel {
    
    let text: String
    
    required init(aboutText: AboutTextModel) {
        
        self.text = aboutText.text
    }
}
