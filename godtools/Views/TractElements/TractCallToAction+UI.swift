//
//  TractCallToAction+UI.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractCallToAction {
    
    func addArrowButton() {
        let xPosition = self.buttonXPosition
        let yPosition = (self.height - self.buttonSizeConstant) / 2
        let origin = CGPoint(x: xPosition, y: yPosition)
        let size = CGSize(width: self.buttonSizeConstant, height: self.buttonSizeConstant)
        let buttonFrame = CGRect(origin: origin, size: size)
        let button = UIButton(type: .system)
        button.frame = buttonFrame
        let image = UIImage(named: "right_arrow_blue")
        button.setImage(image, for: UIControlState.normal)
        button.tintColor = callToActionProperties().controlColor
        button.addTarget(self, action: #selector(moveToNextView), for: UIControlEvents.touchUpInside)
        self.addSubview(button)
    }
    
}
