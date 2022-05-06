//
//  ToolsMenuToolbarView.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol ToolsMenuToolbarViewDelegate: AnyObject {
    
    func toolsMenuToolbarLessonsTapped(toolsMenuToolbar: ToolsMenuToolbarView)
    func toolsMenuToolbarFavoritedToolsTapped(toolsMenuToolbar: ToolsMenuToolbarView)
    func toolsMenuToolbarAllToolsTapped(toolsMenuToolbar: ToolsMenuToolbarView)
}

class ToolsMenuToolbarView: UIView, NibBased {
    
    enum ToolbarItemView {
        case lessons
        case favoritedTools
        case allTools
    }
    
    private var viewModel: ToolsMenuToolbarViewModelType?
    private var selectedToolbarItem: ToolbarItemView = .lessons
    private weak var delegate: ToolsMenuToolbarViewDelegate?
    
    let toolbarItemViews: [ToolbarItemView] = [.lessons, .favoritedTools, .allTools]
    
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
        
    }
    
    func setSelectedToolbarItem(toolbarItem: ToolbarItemView) {
        
        guard toolbarItemsCollectionView != nil else {
            return
        }
        
        selectedToolbarItem = toolbarItem
        toolbarItemsCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource

extension ToolsMenuToolbarView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return toolbarItemViews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let toolbarItemView: ToolbarItemView = toolbarItemViews[indexPath.row]
        
        switch toolbarItemView {
        case .lessons:
            delegate?.toolsMenuToolbarLessonsTapped(toolsMenuToolbar: self)
        case .favoritedTools:
            delegate?.toolsMenuToolbarFavoritedToolsTapped(toolsMenuToolbar: self)
        case .allTools:
            delegate?.toolsMenuToolbarAllToolsTapped(toolsMenuToolbar: self)
        }
        
        selectedToolbarItem = toolbarItemView
        toolbarItemsCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = toolbarItemsCollectionView.dequeueReusableCell(
            withReuseIdentifier: ToolsMenuToolbarItemView.reuseIdentifier,
            for: indexPath
        ) as! ToolsMenuToolbarItemView
        
        let toolbarItemView: ToolbarItemView = toolbarItemViews[indexPath.row]
        
        let cellViewModel: ToolsMenuToolbarItemViewModelType?
        
        switch toolbarItemView {
        case .lessons:
            cellViewModel = viewModel?.lessonsToolbarItemWillAppear()
        case .favoritedTools:
            cellViewModel = viewModel?.favoritedToolsToolbarItemWillAppear()
        case .allTools:
            cellViewModel = viewModel?.allToolsToolbarItemWillAppear()
        }
        
        if let cellViewModel = cellViewModel {
            
            cell.configure(
                viewModel: cellViewModel,
                isSelected: toolbarItemView == selectedToolbarItem
            )
        }
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfItems: CGFloat = CGFloat(toolbarItemViews.count)
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
