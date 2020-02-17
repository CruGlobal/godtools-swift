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
        
        itemsCollectionView.delegate = self
        itemsCollectionView.dataSource = self
    }
    
    private func setupLayout() {
        
        itemsControl.layer.shadowColor = UIColor.black.cgColor
        itemsControl.layer.shadowOffset = CGSize(width: 0, height: 1)
        itemsControl.layer.shadowRadius = 5
        itemsControl.layer.shadowOpacity = 0.3
        
        itemsCollectionView.register(
            UINib(nibName: AccountItemCell.nibName, bundle: nil),
            forCellWithReuseIdentifier: AccountItemCell.reuseIdentifier
        )
    }
    
    private func setupBinding() {
        
        title = viewModel.navTitle
        
        itemsControl.configure(
            segments: viewModel.items,
            delegate: nil
        )
    }
}

extension AccountView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                        
        let cell: AccountItemCell = itemsCollectionView.dequeueReusableCell(
            withReuseIdentifier: AccountItemCell.reuseIdentifier,
            for: indexPath) as! AccountItemCell
        
        let accountItem = viewModel.items[indexPath.row]
        let viewModel = AccountItemCellViewModel(item: accountItem)
        
        cell.configure(viewModel: viewModel)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemsCollectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
