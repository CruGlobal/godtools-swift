//
//  MobileContentTabsView.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentTabsView: MobileContentView {
    
    private let viewModel: MobileContentTabsViewModelType
    
    @IBOutlet weak private var tabsControl: UISegmentedControl!
    @IBOutlet weak private var tabContentContainerView: UIView!
    
    required init(viewModel: MobileContentTabsViewModelType) {
        
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
        
        let nib: UINib = UINib(nibName: String(describing: MobileContentTabsView.self), bundle: nil)
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
        tabsControl.semanticContentAttribute = viewModel.languageDirectionSemanticContentAttribute
        tabsControl.removeAllSegments()
        for index in 0 ..< viewModel.tabLabels.count {
            let tabLabel: String = viewModel.tabLabels[index]
            tabsControl.insertSegment(withTitle: tabLabel, at: index, animated: false)
        }
        
        viewModel.selectedTab.addObserver(self) { [weak self] (selectedTab: Int) in
            self?.tabsControl.selectedSegmentIndex = selectedTab
        }
        
        viewModel.tabContent.addObserver(self) { [weak self] (tabContentViewModel: ToolPageContentStackContainerViewModel?) in
            guard let contentViewModel = tabContentViewModel else {
                return
            }
            self?.setContentView(contentViewModel: contentViewModel)
        }
    }
    
    @objc func handleTabChanged() {
        viewModel.tabTapped(tab: tabsControl.selectedSegmentIndex)
    }
    
    private func setContentView(contentViewModel: ToolPageContentStackContainerViewModel) {
        
        // TODO: Fix this for new renderer changes. ~Levi
        
        /*
        
        for view in tabContentContainerView.subviews {
            view.removeFromSuperview()
        }
        
        let contentView = MobileContentStackView(viewRenderer: contentViewModel.contentStackRenderer, itemSpacing: 10, scrollIsEnabled: false)
        
        tabContentContainerView.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.constrainEdgesToSuperview()
        
        layoutIfNeeded()*/
    }
    
    // MARK: - MobileContentView
    
    override var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .constrainedToChildren
    }
    
    // MARK: -
}
