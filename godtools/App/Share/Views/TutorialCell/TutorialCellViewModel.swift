//
//  TutorialCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TutorialCellViewModel: TutorialCellViewModelType {
        
    let title: String
    let message: String
    let mainImageName: String?
    let youTubeVideoId: String?
    let animationName: String?
    let customView: UIView?
    
    required init(item: TutorialItemType, customViewBuilder: CustomViewBuilderType?) {
        
        title = item.title
        message = item.message
        mainImageName = item.imageName
        youTubeVideoId = item.youTubeVideoId
        animationName = item.animationName
        
        if let customViewId = item.customViewId, !customViewId.isEmpty, let builtCustomView = customViewBuilder?.buildCustomView(customViewId: customViewId) {
            customView = builtCustomView
        }
        else {
            customView = nil
        }
    }
}
