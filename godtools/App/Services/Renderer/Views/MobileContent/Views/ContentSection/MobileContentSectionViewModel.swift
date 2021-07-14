//
//  MobileContentSectionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentSectionViewModel: MobileContentSectionViewModelType {
    
    private let sectionModel: ContentSectionModelType
    private let pageModel: MobileContentRendererPageModel
    
    required init(sectionModel: ContentSectionModelType, pageModel: MobileContentRendererPageModel) {
        
        self.sectionModel = sectionModel
        self.pageModel = pageModel
    }
}
