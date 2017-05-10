//
//  TractLabelGestures.swift
//  godtools
//
//  Created by Devserker on 5/4/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractLabel {
    
    func setupPressGestures() {
        if (self.parent?.isKind(of: Card.self))! {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            
            let frame = CGRect(x: 0.0,
                               y: 0.0,
                               width: self.width,
                               height: 60.0)
            self.tapView.frame = frame
            self.tapView.addGestureRecognizer(tapGesture)
            self.tapView.isUserInteractionEnabled = true
            self.addSubview(self.tapView)
        }
    }
    
    func handleGesture(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let cardView = self.parent as! Card
            cardView.didTapOnCard()
        }
    }
    
}
