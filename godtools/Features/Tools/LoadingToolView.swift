//
//  LoadingToolView.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class LoadingToolView: UIViewController {
    
    private let viewModel: LoadingToolViewModelType
        
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
    @IBOutlet weak private var progressView: ProgressView!
    @IBOutlet weak private var progressLabel: UILabel!
    
    required init(viewModel: LoadingToolViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: LoadingToolView.self), bundle: nil)
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
        
        progressView.progress = 0
    }
    
    private func setupBinding() {
        
        viewModel.isLoading.addObserver(self) { [weak self] (isLoading: Bool) in
            isLoading ? self?.loadingView.startAnimating() : self?.loadingView.stopAnimating()
        }
        
        viewModel.downloadProgress.addObserver(self) { [weak self] (progress: Double) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self?.progressView.progress = CGFloat(progress)
            }, completion: nil)
        }
        
        viewModel.alertMessage.addObserver(self) { [weak self] (alertMessage: AlertMessageType?) in
            guard let alertMessage = alertMessage else {
                return
            }
            self?.presentAlertMessage(alertMessage: alertMessage)
        }
    }
}
