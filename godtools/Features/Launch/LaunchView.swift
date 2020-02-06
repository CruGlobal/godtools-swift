//
//  LaunchView.swift
//  godtools
//
//  Created by Levi Eggert on 1/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

@IBDesignable
class LaunchView: UIViewController {
    
    @IBOutlet weak private var backgroundImageView: UIImageView!
    
    required init() {
        super.init(nibName: "LaunchView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
    }
}
