//
//  ToolPageContentTabsView.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageContentTabsView: UIView {
    
    private let viewModel: ToolPageContentTabsViewModel
    
    @IBOutlet weak private var tabsControl: UISegmentedControl!
    @IBOutlet weak private var tabContentContainerView: UIView!
    
    required init(viewModel: ToolPageContentTabsViewModel) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib()
        setupLayout()
        setupBinding()
        
        tabsControl.addTarget(self, action: #selector(handleTabChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func initializeNib() {
        
        let nib: UINib = UINib(nibName: String(describing: ToolPageContentTabsView.self), bundle: nil)
        let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
        if let rootNibView = (contents as? [UIView])?.first {
            addSubview(rootNibView)
            rootNibView.frame = bounds
            rootNibView.translatesAutoresizingMaskIntoConstraints = false
            rootNibView.constrainEdgesToSuperview()
        }
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
        // tabsControl
        tabsControl.removeAllSegments()
        for index in 0 ..< viewModel.tabLabels.count {
            let tabLabel: String = viewModel.tabLabels[index]
            tabsControl.insertSegment(withTitle: tabLabel, at: index, animated: false)
        }
        
        viewModel.selectedTab.addObserver(self) { [weak self] (selectedTab: Int) in
            self?.tabsControl.selectedSegmentIndex = selectedTab
        }
        
        viewModel.tabContent.addObserver(self) { [weak self] (tabContentViewModel: ToolPageContentStackViewModel?) in
            guard let contentViewModel = tabContentViewModel else {
                return
            }
            self?.setContentView(contentViewModel: contentViewModel)
        }
    }
    
    @objc func handleTabChanged() {
        viewModel.tabTapped(tab: tabsControl.selectedSegmentIndex)
    }
    
    private func setContentView(contentViewModel: ToolPageContentStackViewModel) {
        
        for view in tabContentContainerView.subviews {
            view.removeFromSuperview()
        }
        
        let contentView = ToolPageContentStackView(viewModel: contentViewModel)
        
        tabContentContainerView.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.constrainEdgesToSuperview()
        
        layoutIfNeeded()
    }
}
