//
//  UIView+RemoveAllSubviews.swift
//  godtools
//
//  Created by Levi Eggert on 12/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

extension UIView {
    func removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
}
