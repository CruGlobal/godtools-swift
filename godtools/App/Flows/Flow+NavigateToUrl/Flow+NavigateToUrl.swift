//
//  Flow+NavigateToUrl.swift
//  godtools
//
//  Created by Levi Eggert on 7/27/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

extension Flow {
    
    func navigateToURL(url: URL, exitLink: ExitLinkModel) {
        
        appDiContainer.getExitLinkAnalytics().trackExitLink(exitLink: exitLink)
        
        UIApplication.shared.open(url)
    }
}
