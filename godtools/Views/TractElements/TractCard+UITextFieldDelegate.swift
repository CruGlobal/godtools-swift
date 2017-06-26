//
//  TractCard+UITextFieldDelegate.swift
//  godtools
//
//  Created by Pablo Marti on 6/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractCard: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let yTransformation: CGFloat = -80.0
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.containerView.transform = CGAffineTransform(translationX: 0, y: yTransformation) },
                       completion: nil )
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.containerView.transform = CGAffineTransform(translationX: 0, y: 0) },
                       completion: nil )
        endCardEditing()
        return true
    }
    
}
