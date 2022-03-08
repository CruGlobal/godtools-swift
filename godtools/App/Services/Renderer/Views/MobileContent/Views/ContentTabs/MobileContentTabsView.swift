//
//  MobileContentTabsView.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentTabsView: MobileContentView {
    
    private let viewModel: MobileContentTabsViewModelType
    
    private var tabViews: [MobileContentTabView] = Array()
    
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
        
        tabsControl.removeAllSegments()
    }
    
    private func setupBinding() {
        
        tabsControl.semanticContentAttribute = viewModel.languageDirectionSemanticContentAttribute
    }
    
    // MARK: - MobileContentView
    
    override func renderChild(childView: MobileContentView) {
        
        super.renderChild(childView: childView)
        
        if let tabView = childView as? MobileContentTabView {
            addTabView(tabView: tabView)
        }
    }
    
    override func finishedRenderingChildren() {
        
        setSelectedTabIndex(selectedTabIndex: 0)
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
    
    override func didReceiveEvents(eventIds: [EventId]) {
                
        for eventId in eventIds {
            
            for tabIndex in 0 ..< tabViews.count {
                
                let tabListeners: [EventId] = tabViews[tabIndex].viewModel.tabListeners
                
                if tabListeners.contains(eventId) {
                    setSelectedTabIndex(selectedTabIndex: tabIndex)
                }
            }
        }
    }
}

// MARK: - Tabs

extension MobileContentTabsView {
    
    private func addTabView(tabView: MobileContentTabView) {
        
        tabViews.append(tabView)
        
        let index: Int = tabsControl.numberOfSegments
        
        tabsControl.insertSegment(
            withTitle: tabView.viewModel.labelText ?? "",
            at: index,
            animated: false
        )
    }
    
    private func setSelectedTabIndex(selectedTabIndex: Int) {
        
        guard selectedTabIndex >= 0 && selectedTabIndex < tabViews.count else {
            return
        }
        
        tabsControl.selectedSegmentIndex = selectedTabIndex
        
        let tabView: MobileContentTabView = tabViews[selectedTabIndex]

        tabView.viewModel.tabTapped()
        
        setTabContentContainerTabView(tabView: tabView)
    }
    
    private func setTabContentContainerTabView(tabView: MobileContentTabView) {
        
        for view in tabContentContainerView.subviews {
            view.removeFromSuperview()
        }
                
        tabContentContainerView.addSubview(tabView)
        
        tabView.translatesAutoresizingMaskIntoConstraints = false
        tabView.constrainEdgesToSuperview()
        
        layoutIfNeeded()
    }
    
    @objc func handleTabChanged() {
                
        setSelectedTabIndex(selectedTabIndex: tabsControl.selectedSegmentIndex)
    }
}
