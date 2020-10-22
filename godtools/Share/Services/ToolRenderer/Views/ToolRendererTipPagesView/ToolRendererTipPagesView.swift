//
//  ToolRendererTipPagesView.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolRendererTipPagesView: UIViewController {
    
    private let viewModel: ToolRendererTipPagesViewModelType
            
    @IBOutlet weak private var overlayButton: UIButton!
    @IBOutlet weak private var tipsView: UIView!
    @IBOutlet weak private var tipPagesNavigationView: PageNavigationCollectionView!
    @IBOutlet weak private var closeButton: UIButton!
    @IBOutlet weak private var progressView: ProgressView!
    @IBOutlet weak private var continueButton: UIButton!
    
    required init(viewModel: ToolRendererTipPagesViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: ToolRendererTipPagesView.self), bundle: nil)
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
        
    }
    
    private func setupBinding() {
        
    }
}
