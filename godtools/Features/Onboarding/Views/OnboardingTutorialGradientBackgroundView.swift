//
//  OnboardingTutorialGradientBackgroundView.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialGradientBackgroundView: UIView {
    
    required init() {
        super.init(frame: UIScreen.main.bounds)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        
        backgroundColor = .white
        
        let gradientLayer = CAGradientLayer()

        gradientLayer.colors = [
          UIColor(red: 0.957, green: 0.984, blue: 1, alpha: 1).cgColor,
          UIColor(red: 0.957, green: 0.984, blue: 1, alpha: 0).cgColor
        ]
        
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 0.94, ty: 0))
        gradientLayer.bounds = bounds.insetBy(dx: -0.5*bounds.size.width, dy: -0.5*bounds.size.height)
        gradientLayer.position = center

        layer.addSublayer(gradientLayer)
    }
}
