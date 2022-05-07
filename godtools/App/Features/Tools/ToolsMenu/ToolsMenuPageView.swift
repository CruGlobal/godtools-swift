//
//  ToolsMenuPageView.swift
//  godtools
//
//  Created by Levi Eggert on 5/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

protocol ToolsMenuPageView: UIViewController {
    
    func pageViewed()
    func scrollToTop(animated: Bool)
}
