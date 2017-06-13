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
        self.backgroundColor = .clear
        
        guard let image = self.properties.styleProperties.backgroundImage else {
            return
        }
        let imageView = UIImageView(image: image)
        
        let viewWidth = self.frame.size.width
        let viewHeight = self.frame.size.height
        var width = image.size.width
        var height = image.size.height
        let ratio = width / height
        
        if height > viewHeight || width > viewWidth {
            width = viewWidth
            height = width / ratio
        }
        
        let xPosition = (viewWidth - width) / CGFloat(2.0)
        let yPosition: CGFloat = 0.0
        
        imageView.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        imageView.contentMode = .scaleAspectFit
        
        self.addSubview(imageView)
        self.sendSubview(toBack: imageView)
    }
    
    func setupTransparentView() {
        if self.externalHeight >= self.internalHeight {
            return
        }
        
        let width = self.scrollView.frame.size.width - 6.0
        let height: CGFloat = 60.0
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
    
    func setBordersAndShadows() {
        self.shadowView.frame = self.bounds
        self.shadowView.backgroundColor = .white
        let shadowLayer = self.shadowView.layer
        shadowLayer.cornerRadius = 3.0
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowRadius = 3.0
        shadowLayer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        shadowLayer.shadowOpacity = 0.4
        shadowLayer.shouldRasterize = true
    }
    
    func setupScrollView() {
        let height = self.bounds.size.height
        let scrollViewFrame = CGRect(x: 0.0, y: 0.0, width: self.contentWidth, height: height)
        
        let contentHeight = self.internalHeight
        self.scrollView.contentSize = CGSize(width: self.contentWidth, height: contentHeight)
        self.scrollView.frame = scrollViewFrame
        self.scrollView.delegate = self
        self.scrollView.backgroundColor = .gtWhite
        self.scrollView.showsVerticalScrollIndicator = false
        self.containerView.frame = CGRect(x: 0.0,
                                          y: 0.0,
                                          width: self.contentWidth,
                                          height: contentHeight)
        self.containerView.backgroundColor = .clear
    }
    
}
