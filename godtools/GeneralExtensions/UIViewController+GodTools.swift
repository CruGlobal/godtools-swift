//
//  UIViewController+GodTools.swift
//  godtools
//
//  Created by Igor Ostriz on 24/12/2018.
//  Copyright © 2018 Cru. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showSimpleAlert(title: String?, message: String?, closeButtonTitle: String = "ok".localized, complete:(() -> Void)?) -> Void {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: closeButtonTitle, style: .cancel, handler: { action in
            if complete != nil {
                complete!()
            }
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Show the no internet message
    func showNoInternetAlert(){
        let alertController = UIAlertController(title: "no_internet_title".localized(default: "No internet connection"), message: "no_internet".localized(default: "Please check your internet connection and try again."), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok".localized, style: .cancel, handler: { action in
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

}
