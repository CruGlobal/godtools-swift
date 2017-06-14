//
//  TractCards+UI.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractCards {
    
    func setupBackground() {
        self.backgroundColor = .clear
        
        guard let image = self.page?.pageProperties().backgroundImage else {
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
    
}
