//
//  TractCard+UI.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractCard {
    
    func setupBackground() {
        let elementProperties = self.cardProperties()
        if elementProperties.backgroundImage == "" {
            return
        }
        
        let imagePath = self.manifestProperties.getResourceForFile(filename: elementProperties.backgroundImage)
        
        guard let data = NSData(contentsOfFile: imagePath) else {
            return
        }
        
        guard let image = UIImage(data: data as Data) else {
            return
        }
        
        let imageView = buildScaledImageView(parentView: self.backgroundView,
                                             image: image,
                                             aligns: elementProperties.backgroundImageAlign,
                                             scaleType: elementProperties.backgroundImageScaleType)
        
        self.backgroundView.addSubview(imageView)
        self.backgroundView.clipsToBounds = true
    }
    
    func setupTransparentView() {
        if self.externalHeight >= self.internalHeight {
            return
        }
        
        let width = self.scrollView.frame.size.width - 6.0
        let height: CGFloat = TractCard.transparentViewHeight
        let xPosition: CGFloat = 3.0
        let yPosition = self.scrollView.frame.size.height - height - 1.0
        let transparentViewFrame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        let transparentView = UIView(frame: transparentViewFrame)
        transparentView.backgroundColor = .clear
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = transparentView.bounds
        gradientLayer.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor]
        transparentView.layer.insertSublayer(gradientLayer, at: 0)
        
        self.addSubview(transparentView)
    }
    
    func setupScrollView() {
        let width = self.elementFrame.finalWidth() - (TractCard.shadowPaddingConstant * CGFloat(2))
        let xPosition = (self.elementFrame.finalWidth() - width) / CGFloat(2)
        let height = self.bounds.size.height
        let scrollViewFrame = CGRect(x: xPosition, y: 0.0, width: width, height: height)
        
        self.scrollView.contentSize = CGSize(width: width, height: self.internalHeight)
        self.scrollView.frame = scrollViewFrame
        self.scrollView.delegate = self
        self.scrollView.backgroundColor = .clear
        self.scrollView.showsVerticalScrollIndicator = false
        
        self.backgroundView.frame = scrollViewFrame
        
        self.containerView.frame = CGRect(x: 0.0,
                                          y: 0.0,
                                          width: width,
                                          height: self.internalHeight)
        self.containerView.backgroundColor = .clear
    }
    
    func setBordersAndShadows() {
        self.shadowView.frame = self.bounds
        self.shadowView.backgroundColor = cardBackgroundColor()
        let shadowLayer = self.shadowView.layer
        shadowLayer.cornerRadius = 3.0
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowRadius = 3.0
        shadowLayer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        shadowLayer.shadowOpacity = 0.4
        shadowLayer.shouldRasterize = true
    }
    
    func cardBackgroundColor() -> UIColor {
        let elementProperties = cardProperties()
        return elementProperties.backgroundColor
    }
    
}
