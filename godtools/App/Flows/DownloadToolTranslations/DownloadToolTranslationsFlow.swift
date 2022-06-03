//
//  DownloadToolTranslationsFlow.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class DownloadToolTranslationsFlow: Flow {
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController = UINavigationController()
    
    required init(appDiContainer: AppDiContainer) {
        
        self.appDiContainer = appDiContainer
    }
    
    func navigate(step: FlowStep) {
        
    }
}

