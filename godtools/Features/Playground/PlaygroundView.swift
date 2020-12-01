//
//  PlaygroundView.swift
//  mpdx-ios
//
//  Created by Levi Eggert on 10/8/20.
//  Copyright © 2020 Cru Global, Inc. All rights reserved.
//

import UIKit

class PlaygroundView: UIViewController {
    
    private let viewModel: PlaygroundViewModel
                
    required init(viewModel: PlaygroundViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: PlaygroundView.self), bundle: nil)
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
        
        _ = addBarButtonItem(
            to: .left,
            image: UIImage(named: "nav_item_close"),
            color: nil,
            target: self,
            action: #selector(handleClose(barButtonItem:))
        )
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
    }
    
    @objc func handleClose(barButtonItem: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
