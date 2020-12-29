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
    
    private var toolsMenuControl: UISegmentedControl = UISegmentedControl()
                
    @IBOutlet weak private var favoritedTools: FavoritedToolsView!
    @IBOutlet weak private var allTools: AllToolsView!
        
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
        
        favoritedTools.configure(viewModel: favoritedToolsViewModel, delegate: self, openTutorialViewModel: openTutorialViewModel)
        allTools.configure(viewModel: allToolsViewModel, favoritingToolMessageViewModel: favoritingToolMessageViewModel)
        
        setupLayout()
        setupBinding()
        
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
        
        toolsMenuControl.addTarget(
            self,
            action: #selector(handleToolsMenuControlChanged(toolsControl:)),
            for: .valueChanged
        )
    }
    
    func resetMenu() {
        favoritedTools.scrollToTopOfTools(animated: false)
        allTools.scrollToTopOfTools(animated: false)
        viewModel.resetMenu()
    }
    
    private func setupLayout() {
        toolsMenuControl.accessibilityIdentifier = "home_nav_segmented_control"
    }
    
    private func setupBinding() {
        
        viewModel.toolMenuItems.addObserver(self) { [weak self] (toolMenuItems: [ToolMenuItem]) in
            self?.reloadToolsMenuControl()
        }
        
        viewModel.selectedToolMenuItem.addObserver(self) { [weak self] (toolMenuItem: ToolMenuItem?) in
            if let toolMenuItem = toolMenuItem, let menuItems = self?.viewModel.toolMenuItems.value, let index = menuItems.firstIndex(of: toolMenuItem) {
                self?.toolsMenuControl.selectedSegmentIndex = index
                self?.navigateToToolMenuItem(menuItem: toolMenuItem, animated: true)
            }
        }
    }
    
    @objc func handleMenu(barButtonItem: UIBarButtonItem) {
        viewModel.menuTapped()
    }
    
    @objc func handleLanguage(barButtonItem: UIBarButtonItem) {
        viewModel.languageTapped()
    }
    
    @objc func handleToolsMenuControlChanged(toolsControl: UISegmentedControl) {
        
        let menuItem: ToolMenuItem = viewModel.toolMenuItems.value[toolsControl.selectedSegmentIndex]

        viewModel.toolMenuItemTapped(menuItem: menuItem)
    }
    
    private func reloadToolsMenuControl() {
        
        toolsMenuControl.removeAllSegments()
        
        for index in 0 ..< viewModel.toolMenuItems.value.count {
            let menuItem: ToolMenuItem = viewModel.toolMenuItems.value[index]
            toolsMenuControl.insertSegment(withTitle: menuItem.title, at: index, animated: false)
        }
        
        let titleFont: UIFont = FontLibrary.sfProTextRegular.font(size: 15) ?? UIFont.systemFont(ofSize: 15)
                        
        if #available(iOS 13.0, *) {
            toolsMenuControl.setTitleTextAttributes([.font: titleFont, .foregroundColor: UIColor.white], for: .normal)
            toolsMenuControl.setTitleTextAttributes([.font: titleFont, .foregroundColor: UIColor(red: 0 / 255, green: 173 / 255, blue: 218 / 255, alpha: 1)], for: .selected)
            toolsMenuControl.layer.borderColor = UIColor.white.cgColor
            toolsMenuControl.layer.borderWidth = 1
            toolsMenuControl.selectedSegmentTintColor = .white
            toolsMenuControl.backgroundColor = .clear
        }
        else {
            toolsMenuControl.setTitleTextAttributes([.font: titleFont], for: .normal)
        }
        
        navigationItem.titleView = toolsMenuControl
    }
    
    private func navigateToToolMenuItem(menuItem: ToolMenuItem, animated: Bool) {
                
        switch menuItem.id {
        case .favorites:
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
                
        if let index = viewModel.toolMenuItems.value.firstIndex(of: viewModel.allToolsMenuItem) {
            toolsMenuControl.selectedSegmentIndex = index
            handleToolsMenuControlChanged(toolsControl: toolsMenuControl)
        }
    }
}
