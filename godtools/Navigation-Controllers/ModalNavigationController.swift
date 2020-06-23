//
//  ModalNavigationController.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ModalNavigationController: UINavigationController {
    
    private let rootView: UIViewController
    private let hidesNavigationBar: Bool
    private let hidesCloseButton: Bool
    private let closeHandler: CallbackHandler?
    
    required init(rootView: UIViewController, hidesNavigationBar: Bool, closeHandler: CallbackHandler?) {
        self.rootView = rootView
        self.hidesNavigationBar = hidesNavigationBar
        self.hidesCloseButton = closeHandler == nil || hidesNavigationBar
        self.closeHandler = !hidesNavigationBar ? closeHandler : nil
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationBar.barTintColor = UIColor.white
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
        
        setNavigationBarHidden(hidesNavigationBar, animated: false)
                
        setViewControllers([rootView], animated: false)
        
        if !hidesNavigationBar && !hidesCloseButton {
            _ = rootView.addBarButtonItem(
                to: .right,
                image: ImageCatalog.navClose.image,
                color: UIColor(red: 0.231, green: 0.643, blue: 0.859, alpha: 1),
                target: self,
                action: #selector(handleClose(barButtonItem:))
            )
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @objc func handleClose(barButtonItem: UIBarButtonItem) {
        closeHandler?.handle()
    }
}
