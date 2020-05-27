//
//  ToolsView.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolsView: UIViewController {
    
    private let viewModel: ToolsViewModelType
    private let openTutorialViewModel: OpenTutorialViewModelType
    private let myToolsView: MyToolsView
    private let allToolsView: AllToolsView
    
    private var toolsControl: UISegmentedControl = UISegmentedControl()
                
    @IBOutlet weak private var openTutorialView: OpenTutorialView!
    @IBOutlet weak private var favoritedToolsContainerView: UIView!
    @IBOutlet weak private var allToolsContainerView: UIView!
    
    @IBOutlet weak private var openTutorialTop: NSLayoutConstraint!
    @IBOutlet weak private var openTutorialHeight: NSLayoutConstraint!
    @IBOutlet weak private var favoritedToolsContainerLeading: NSLayoutConstraint!
    
    required init(viewModel: ToolsViewModelType, openTutorialViewModel: OpenTutorialViewModelType, myToolsViewModel: MyToolsViewModelType, allToolsViewModel: AllToolsViewModelType) {
        self.viewModel = viewModel
        self.openTutorialViewModel = openTutorialViewModel
        myToolsView = MyToolsView(viewModel: myToolsViewModel)
        allToolsView = AllToolsView(viewModel: allToolsViewModel)
        super.init(nibName: String(describing: ToolsView.self), bundle: nil)
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
        
        toolsControl.addTarget(
            self,
            action: #selector(handleToolControlChanged(toolsControl:)),
            for: .valueChanged
        )
    }
    
    private func setupLayout() {
        
        // toolsControl
        toolsControl.accessibilityIdentifier = GTAccessibilityConstants.Home.homeNavSegmentedControl
        
        // myToolsView
        addChildController(child: myToolsView, toView: favoritedToolsContainerView)
        myToolsView.view.constrainEdgesToSuperview()
        
        // allToolsView
        addChildController(child: allToolsView, toView: allToolsContainerView)
        allToolsView.view.constrainEdgesToSuperview()
    }
    
    private func setupBinding() {
        
        openTutorialView.configure(viewModel: openTutorialViewModel)
        openTutorialViewModel.hidesOpenTutorial.addObserver(self) { [weak self] (tuple: (hidden: Bool, animated: Bool)) in
            self?.setOpenTutorialHidden(tuple.hidden, animated: tuple.animated)
        }
        
        viewModel.toolMenuItems.addObserver(self) { [weak self] (toolMenuItems: [ToolMenuItem]) in
            self?.reloadToolsControl()
        }
        
        viewModel.selectedToolMenuItemIndex.addObserver(self) { [weak self] (selectedToolMenuItemIndex: Int) in
            self?.toolsControl.selectedSegmentIndex = selectedToolMenuItemIndex
        }
    }
    
    @objc func handleMenu(barButtonItem: UIBarButtonItem) {
        viewModel.menuTapped()
    }
    
    @objc func handleLanguage(barButtonItem: UIBarButtonItem) {
        viewModel.languageTapped()
    }
    
    @objc func handleToolControlChanged(toolsControl: UISegmentedControl) {
        
        let menuItem: ToolMenuItem = viewModel.toolMenuItems.value[toolsControl.selectedSegmentIndex]
        
        viewModel.toolMenuItemTapped(menuItem: menuItem)
        
        navigateToToolMenuItem(menuItem: menuItem, animated: true)
    }
    
    private func setOpenTutorialHidden(_ hidden: Bool, animated: Bool) {
        openTutorialTop.constant = hidden ? (openTutorialHeight.constant * -1) : 0
        
        if animated {
            if !hidden {
                openTutorialView.isHidden = false
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.view.layoutIfNeeded()
                }, completion: { [weak self] (finished: Bool) in
                    if hidden {
                        self?.openTutorialView.isHidden = true
                    }
            })
        }
        else {
            openTutorialView.isHidden = hidden
            view.layoutIfNeeded()
        }
    }
    
    private func reloadToolsControl() {
        
        toolsControl.removeAllSegments()
        
        for index in 0 ..< viewModel.toolMenuItems.value.count {
            let menuItem: ToolMenuItem = viewModel.toolMenuItems.value[index]
            toolsControl.insertSegment(withTitle: menuItem.title, at: index, animated: false)
        }
        
        let titleFont: UIFont = UIFont.defaultFont(size: 15, weight: nil)
                
        if #available(iOS 13.0, *) {
            toolsControl.setTitleTextAttributes([.font: titleFont, .foregroundColor: UIColor.white], for: .normal)
            toolsControl.setTitleTextAttributes([.font: titleFont, .foregroundColor: UIColor(red: 0 / 255, green: 173 / 255, blue: 218 / 255, alpha: 1)], for: .selected)
            toolsControl.layer.borderColor = UIColor.white.cgColor
            toolsControl.layer.borderWidth = 1
            toolsControl.selectedSegmentTintColor = .white
            toolsControl.backgroundColor = .clear
        }
        else {
            toolsControl.setTitleTextAttributes([.font: titleFont], for: .normal)
        }
        
        navigationItem.titleView = toolsControl
    }
    
    private func navigateToToolMenuItem(menuItem: ToolMenuItem, animated: Bool) {
        
        let favoritesLeading: CGFloat
        
        switch menuItem.id {
        case .favorites:
            favoritesLeading = 0
        case .allTools:
            favoritesLeading = view.bounds.size.width * -1
        }
        
        favoritedToolsContainerLeading.constant = favoritesLeading
        
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
