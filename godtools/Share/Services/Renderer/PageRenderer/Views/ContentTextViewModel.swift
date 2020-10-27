//
//  ContentTextViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ContentTextViewModel {
    
    let text: String
    
    required init(textModel: ContentTextModel) {
        
        text = textModel.text ?? ""
    }
}
