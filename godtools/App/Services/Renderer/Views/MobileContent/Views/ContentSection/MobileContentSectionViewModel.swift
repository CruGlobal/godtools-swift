//
//  MobileContentSectionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentSectionViewModel: MobileContentSectionViewModelType {
    
    private let sectionModel: Accordion.Section
    private let rendererPageModel: MobileContentRendererPageModel
    
    required init(sectionModel: Accordion.Section, rendererPageModel: MobileContentRendererPageModel) {
        
        self.sectionModel = sectionModel
        self.rendererPageModel = rendererPageModel
    }
}
