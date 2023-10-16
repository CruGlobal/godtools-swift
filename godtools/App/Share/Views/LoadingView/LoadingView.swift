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
    
    private var closeButton: UIBarButtonItem?
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.pageViewed()
    }
    
    private func setupLayout() {
        messageLabel.text = ""
        loadingView.startAnimating()
    }
    
    private func setupBinding() {
        
        viewModel.message.addObserver(self) { [weak self] (message: String) in
            self?.messageLabel.text = message
        }
        
        setCloseButton(hidden: viewModel.hidesCloseButton)
    }
    
    @objc func handleClose(barButtonItem: UIBarButtonItem) {
        
        viewModel.closeTapped()
    }
    
    private func setCloseButton(hidden: Bool) {
        
        let position: BarButtonItemBarPosition = .trailing
        
        if hidden, let closeButton = closeButton {
            
            removeBarButtonItem(item: closeButton)
            
            self.closeButton = nil
        }
        else if !hidden && closeButton == nil {
            
            closeButton = addBarButtonItem(
                barPosition: position,
                index: 0,
                image: ImageCatalog.navClose.uiImage,
                color: UIColor.black,
                target: self,
                action: #selector(handleClose(barButtonItem:))
            )
        }
    }
}

