//
//  ToolsMenuView.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolsMenuView: UIViewController {
    
    private let viewModel: ToolsMenuViewModelType
    private let openTutorialViewModel: OpenTutorialViewModelType
    private let favoritedToolsViewModel: FavoritedToolsViewModelType
    private let allToolsViewModel: AllToolsViewModelType
    private let favoritingToolMessageViewModel: FavoritingToolMessageViewModelType
    
    private var didLayoutSubviews: Bool = false
                
    @IBOutlet weak private var favoritedTools: FavoritedToolsView!
    @IBOutlet weak private var allTools: AllToolsView!
    @IBOutlet weak private var toolbarView: ToolsMenuToolbarView!
    @IBOutlet weak private var bottomView: UIView!
        
    @IBOutlet weak private var favoritedToolsLeading: NSLayoutConstraint!
    
    required init(viewModel: ToolsMenuViewModelType, openTutorialViewModel: OpenTutorialViewModelType, favoritedToolsViewModel: FavoritedToolsViewModelType, allToolsViewModel: AllToolsViewModelType, favoritingToolMessageViewModel: FavoritingToolMessageViewModelType) {
        
        self.viewModel = viewModel
        self.openTutorialViewModel = openTutorialViewModel
        self.favoritedToolsViewModel = favoritedToolsViewModel
        self.allToolsViewModel = allToolsViewModel
        self.favoritingToolMessageViewModel = favoritingToolMessageViewModel
        super.init(nibName: String(describing: ToolsMenuView.self), bundle: nil)
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
        
        _ = addBarButtonItem(
            to: .left,
            image: ImageCatalog.navMenu.image,
            color: .white,
            target: self,
            action: #selector(handleMenu(barButtonItem:))
        )
        
        _ = addBarButtonItem(
            to: .right,
            image: ImageCatalog.navLanguage.image,
            color: .white,
            target: self,
            action: #selector(handleLanguage(barButtonItem:))
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !didLayoutSubviews {
            didLayoutSubviews = true
            
            favoritedTools.configure(
                viewModel: favoritedToolsViewModel,
                delegate: self,
                openTutorialViewModel: openTutorialViewModel
            )
            
            allTools.configure(
                viewModel: allToolsViewModel,
                favoritingToolMessageViewModel: favoritingToolMessageViewModel
            )
            
            toolbarView.configure(
                viewModel: viewModel.toolbarWillAppear(),
                delegate: self
            )
            
            setupBinding()
        }
    }
    
    func resetMenu() {
        if favoritedTools != nil {
            favoritedTools.scrollToTopOfTools(animated: false)
        }
        if allTools != nil {
            allTools.scrollToTopOfTools(animated: false)
        }
    }
    
    private func setupLayout() {

    }
    
    private func setupBinding() {
        
    }
    
    @objc func handleMenu(barButtonItem: UIBarButtonItem) {
        viewModel.menuTapped()
    }
    
    @objc func handleLanguage(barButtonItem: UIBarButtonItem) {
        viewModel.languageTapped()
    }
    
    private func navigateForTappedToolbarItem(toolbarItem: ToolsMenuToolbarView.ToolbarItemView, animated: Bool) {
                
        switch toolbarItem {
        case .learn:
            // TODO: Navigate to lessons.
            break
        case .favoritedTools:
            favoritedToolsLeading.constant = 0
            favoritedTools.pageViewed()
        case .allTools:
            favoritedToolsLeading.constant = view.bounds.size.width * -1
            allTools.pageViewed()
        }
                
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.view.layoutIfNeeded()
            }, completion: nil)
        }
        else {
            view.layoutIfNeeded()
        }
    }
}

// MARK: - FavoritedToolsViewDelegate

extension ToolsMenuView: FavoritedToolsViewDelegate {
    
    func favoritedToolsViewFindToolsTapped(favoritedToolsView: FavoritedToolsView) {
              
        // TODO: Implement. ~Levi
        /*
        if let index = viewModel.toolMenuItems.value.firstIndex(of: viewModel.allToolsMenuItem) {
            toolsMenuControl.selectedSegmentIndex = index
            handleToolsMenuControlChanged(toolsControl: toolsMenuControl)
        }*/
    }
}

// MARK: - ToolsMenuToolbarViewDelegate

extension ToolsMenuView: ToolsMenuToolbarViewDelegate {
    
    func toolsMenuToolbarLessonsTapped(toolsMenuToolbar: ToolsMenuToolbarView) {
        
    }
    
    func toolsMenuToolbarFavoritedToolsTapped(toolsMenuToolbar: ToolsMenuToolbarView) {
        
    }
    
    func toolsMenuToolbarAllToolsTapped(toolsMenuToolbar: ToolsMenuToolbarView) {
        
    }
}
