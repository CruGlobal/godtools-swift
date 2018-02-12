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
        
        let button = createButton(with: buttonFrame)
        
        self.addSubview(button)
    }
    
    private func createButton(with frame: CGRect) -> UIButton {
        let button = UIButton(type: .system)
        button.frame = frame
        
        let image = UIImage(named: "right_arrow_blue")
        
        let controlColor = callToActionProperties().controlColor;
        let pagePrimaryColor = page?.pageProperties().primaryColor;
        
        button.setImage(image, for: UIControlState.normal)
        button.tintColor = controlColor != nil ? controlColor : pagePrimaryColor
        button.addTarget(self, action: #selector(moveToNextView), for: UIControlEvents.touchUpInside)
        
        return button
    }
}
