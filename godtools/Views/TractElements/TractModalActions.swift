//
//  TractModalActions.swift
//  godtools
//
//  Created by Devserker on 5/29/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractModal {
    
    override func receiveMessage() {
        _ = render()
        
        let currentWindow = UIApplication.shared.keyWindow
        currentWindow?.addSubview(self)
        
        self.alpha = CGFloat(0.0)
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: { self.alpha = CGFloat(1.0) },
                       completion: nil )
    }
    
    override func receiveDismissMessage() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.75,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: { self.alpha = CGFloat(0.0) },
                       completion: { (completed: Bool) in
                        self.removeFromSuperview() } )
    }
    
}
