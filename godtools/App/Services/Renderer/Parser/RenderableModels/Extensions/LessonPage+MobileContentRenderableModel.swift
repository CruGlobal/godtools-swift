//
//  LessonPage+MobileContentRenderableModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

extension LessonPage: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [AnyObject] {
        
        var childModels: [AnyObject] = Array()

        let contentHorizontalInsets: CGFloat = 30
        
        let multiplatformContent = MultiplatformContent(
            content: content,
            contentInsets: UIEdgeInsets(top: 0, left: contentHorizontalInsets, bottom: 0, right: contentHorizontalInsets),
            itemSpacing: 20,
            scrollIsEnabled: true
        )
        
        childModels.append(multiplatformContent)
        
        return childModels
    }
}
