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
        moveViewForPresentingKeyboardAnimation()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done {
            moveViewForDismissingKeyboardAnimation()
            endCardEditing()
            return true
        } else {
            let tractInput = textField.superview as! TractInput
            if let form = BaseTractElement.getFormForElement(tractInput) {
                if let followingTractInput = form.getFollowingInputForInput(element: tractInput) {
                    followingTractInput.textField.becomeFirstResponder()
                }
            }
            
            return false
        }
    }
    
}
