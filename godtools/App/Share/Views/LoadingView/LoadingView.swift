//
//  LoadingView.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class LoadingView: AppViewController {
    
    private let message: String?
    
    @IBOutlet weak private var overlayView: UIView!
    @IBOutlet weak private var logoImageView: UIImageView!
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
    @IBOutlet weak private var messageLabel: UILabel!
        
    init(navigationBar: AppNavigationBar?, message: String?) {
        self.message = message
        super.init(nibName: String(describing: LoadingView.self), bundle: nil, navigationBar: navigationBar)
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
        print("view didload: \(type(of: self))")
        
        setupLayout()
    }

    func setupLayout() {
        messageLabel.text = message
        loadingView.startAnimating()
    }
}

