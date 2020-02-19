//
//  AccountActivityView.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AccountActivityView: UIView, NibBased {
    
    private let viewModel: AccountActivityViewModel
    private let activityCollectionHeaderHeight: CGFloat = 76
    private let activityCollectionHorizontalEdgeInset: CGFloat = 34
    private let activityCollectionCellSpacing: CGFloat = 20
    
    @IBOutlet weak private var activityCollectionView: UICollectionView!
    
    required init(viewModel: AccountActivityViewModel) {
        self.viewModel = viewModel
        super.init(frame: UIScreen.main.bounds)
        initialize()
    }
    
    override init(frame: CGRect) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize() {
        loadNib()
        
        setupLayout()
        setupBinding()
        
        activityCollectionView.delegate = self
        activityCollectionView.dataSource = self
    }
    
    private func setupLayout() {
        
        activityCollectionView.register(
            UINib(nibName: GlobalActivityHeaderView.nibName, bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: GlobalActivityHeaderView.reuseIdentifier
        )
        
        activityCollectionView.register(
            UINib(nibName: GlobalActivityCell.nibName, bundle: nil),
            forCellWithReuseIdentifier: GlobalActivityCell.reuseIdentifier
        )
        
        activityCollectionView.contentInset = UIEdgeInsets(
            top: 16,
            left: activityCollectionHorizontalEdgeInset,
            bottom: 0,
            right: activityCollectionHorizontalEdgeInset
        )
    }
    
    private func setupBinding() {
        
        viewModel.globalActivityAttributes.addObserver(self) { [weak self] (attributes: [GlobalActivityAttribute]) in
            self?.activityCollectionView.reloadData()
        }
        
        viewModel.isLoadingGlobalActivity.addObserver(self) { [weak self] (isLoading: Bool) in
            self?.activityCollectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource

extension AccountActivityView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.globalActivityAttributes.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          
        let cell: GlobalActivityCell = activityCollectionView.dequeueReusableCell(
            withReuseIdentifier: GlobalActivityCell.reuseIdentifier,
            for: indexPath) as! GlobalActivityCell
             
        let globalActivityAttributes = viewModel.globalActivityAttributes.value[indexPath.row]
        let cellViewModel = GlobalActivityCellViewModel(
            globalActivityAttribute: globalActivityAttributes,
            isLoading: viewModel.isLoadingGlobalActivity.value
        )
        
        cell.configure(viewModel: cellViewModel)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellAspectRatio: CGSize = CGSize(width: 146, height: 128)
        let cellWidthFor2Columns: CGFloat = (bounds.size.width - (activityCollectionHorizontalEdgeInset * 2) - activityCollectionCellSpacing) / 2
        let cellHeight: CGFloat = cellWidthFor2Columns * (cellAspectRatio.height / cellAspectRatio.width)
        
        return CGSize(
            width: cellWidthFor2Columns,
            height: cellHeight
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return activityCollectionCellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return activityCollectionCellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            
            let headerView: GlobalActivityHeaderView = activityCollectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: GlobalActivityHeaderView.reuseIdentifier,
                for: indexPath
            ) as! GlobalActivityHeaderView
            
            headerView.configure(viewModel: GlobalActivityHeaderViewModel())
            
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(
            width: activityCollectionView.bounds.size.width,
            height: activityCollectionHeaderHeight)
        
    }
}
