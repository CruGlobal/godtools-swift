//
//  MyToolsView.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MyToolsView: UIViewController {
    
    private let viewModel: MyToolsViewModelType
        
    @IBOutlet weak private var toolsTableView: UITableView!
    
    required init(viewModel: MyToolsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: MyToolsView.self), bundle: nil)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pageViewed()
        
        print("\nMyToolsView: viewWillAppear()")
    }
}
