//
//  LoadingView.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class LoadingView: UIViewController {
    
    private let viewModel: LoadingViewModelType
    
    @IBOutlet weak private var overlayView: UIView!
    @IBOutlet weak private var logoImageView: UIImageView!
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
    @IBOutlet weak private var messageLabel: UILabel!
        
    required init(viewModel: LoadingViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: LoadingView.self), bundle: nil)
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
        setupBinding()
    }
    
    private func setupLayout() {
        messageLabel.text = ""
        loadingView.startAnimating()
    }
    
    private func setupBinding() {
        
        viewModel.message.addObserver(self) { [weak self] (message: String) in
            self?.messageLabel.text = message
        }
    }
}

