//
//  ToolsMenuToolbarView.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ToolsMenuToolbarViewDelegate: class {
    
}

class ToolsMenuToolbarView: UIView, NibBased {
    
    private var viewModel: ToolsMenuToolbarViewModelType?
    
    private weak var delegate: ToolsMenuToolbarViewDelegate?
    
    @IBOutlet weak private var toolbarItemsCollectionView: UICollectionView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
        setupLayout()
    }
    
    func configure(viewModel: ToolsMenuToolbarViewModelType, delegate: ToolsMenuToolbarViewDelegate) {
        
        self.viewModel = viewModel
        self.delegate = delegate
        
        setupBinding()
        
        toolbarItemsCollectionView.delegate = self
        toolbarItemsCollectionView.dataSource = self
    }
    
    private func setupLayout() {
        
        // toolbarItemsCollectionView
        toolbarItemsCollectionView.register(
            UINib(nibName: ToolsMenuToolbarItemView.nibName, bundle: nil),
            forCellWithReuseIdentifier: ToolsMenuToolbarItemView.reuseIdentifier
        )
        
        // shadow
        clipsToBounds = false
        layer.shadowOffset = CGSize(width: 0, height: -1)
        layer.shadowRadius = 4
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
    }
    
    private func setupBinding() {
        
        viewModel?.numberOfToolbarItems.addObserver(self) { [weak self] (numberOfToolbarItems: Int) in
            self?.toolbarItemsCollectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource

extension ToolsMenuToolbarView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfToolbarItems.value ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = toolbarItemsCollectionView.dequeueReusableCell(
            withReuseIdentifier: ToolsMenuToolbarItemView.reuseIdentifier,
            for: indexPath
        ) as! ToolsMenuToolbarItemView
        
        if let cellViewModel = viewModel?.toolbarItemWillAppear(index: indexPath.row) {
            cell.configure(viewModel: cellViewModel)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfItems: CGFloat = CGFloat(viewModel?.numberOfToolbarItems.value ?? 0)
        let width: CGFloat = numberOfItems > 0 ? floor(UIScreen.main.bounds.size.width / numberOfItems) : bounds.size.height
        
        return CGSize(
            width: width,
            height: bounds.size.height
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
