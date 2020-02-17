//
//  AccountView.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AccountView: UIViewController {
    
    private let viewModel: AccountViewModelType
    
    @IBOutlet weak private var headerView: UIView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var joinedLabel: UILabel!
    @IBOutlet weak private var itemsControl: GTSegmentedControl!
    @IBOutlet weak private var itemsCollectionView: UICollectionView!
    
    required init(viewModel: AccountViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: "AccountView", bundle: nil)
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
        
        title = viewModel.navTitle
        
        //itemsControl.configure(segments: viewModel.items, delegate: nil)
        itemsControl.configure(
            segments: [
                GTSegment(id: "", title: "Activity"),
                GTSegment(id: "", title: "Longer Title Goes Here")
            ],
            delegate: nil
        )
    }
}
