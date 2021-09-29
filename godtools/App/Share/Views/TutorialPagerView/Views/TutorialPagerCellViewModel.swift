//
//  TutorialPagerCellViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 9/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class TutorialPagerCellViewModel: TutorialPagerCellViewModelType {
    
    let title: String
    let message: String
    let mainImageName: String?
    let animationName: String?
    let customView: UIView?
    let hideSkip: Bool
    let hideFooter: Bool
    
    required init(item: TutorialPagerItem, customViewBuilder: CustomViewBuilderType) {
        title = item.title
        message = item.message
        mainImageName = item.imageName
        animationName = item.animationName
        hideSkip = item.hideSkip
        hideFooter = item.hideFooter
        
        if let customViewId = item.customViewId, !customViewId.isEmpty, let builtCustomView = customViewBuilder.buildCustomView(customViewId: customViewId) {
            customView = builtCustomView
        }
        else {
            customView = nil
        }
    }
}
