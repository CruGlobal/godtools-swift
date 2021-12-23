//
//  UIViewController+DismissPresented.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // Helper ensures completion will always be called.  I believe if animated is false when calling UIKit's UIViewController.dismiss(animated:) the completion closure will never be called.
    
    func dismissPresented(animated: Bool, completion: @escaping (() -> Void)) {
        
        let isPresenting: Bool = presentedViewController != nil
        
        guard isPresenting else {
            completion()
            return
        }
        
        if animated {
            dismiss(animated: true, completion: completion)
        }
        else {
            dismiss(animated: false)
            completion()
        }
    }
}
