//
//  MobileContentView.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentView: UIView, MobileContentStackChildViewType {
        
    private(set) weak var parent: MobileContentView?
    
    private(set) var children: [MobileContentView] = Array()
    
    var contentStackChildViewDelegate: MobileContentStackChildViewDelegate?
    
    private func getRootView() -> MobileContentView {
        
        if let parentView = parent {
            
            var rootView: MobileContentView = parentView
            var nextParentView: MobileContentView? = parentView.parent
            
            while nextParentView != nil {
                
                if let parentView = nextParentView {
                    rootView = parentView
                }
                
                nextParentView = nextParentView?.parent
            }
            
            return rootView
        }
        
        return self
    }
    
    // MARK: -
    
    func setParentAndAddChild(childView: MobileContentView) {
    
        childView.parent = self
        
        children.append(childView)
    }
    
    func renderChild(childView: MobileContentView) {
        
        setParentAndAddChild(childView: childView)
    }
    
    func finishedRenderingChildren() {
        
    }
    
    func viewDidAppear() {
        for child in children {
            child.viewDidAppear()
        }
    }
    
    func viewDidDisappear() {
        for child in children {
            child.viewDidDisappear()
        }
    }
    
    // MARK: - Events
    
    func sendEventsToAllViews(events: [String]) {
        recurseChildrenAndSendEvents(view: getRootView(), events: events)
    }
    
    private func recurseChildrenAndSendEvents(view: MobileContentView, events: [String]) {
        
        for childView in view.children {
            recurseChildrenAndSendEvents(view: childView, events: events)
        }
        
        view.didReceiveEvents(events: events)
    }
    
    func didReceiveEvents(events: [String]) {
        
    }
    
    // MARK: - Url Events
    
    func sendButtonWithUrlEventToRootView(url: String) {
        getRootView().didReceiveButtonWithUrlEvent(url: url)
    }
    
    func didReceiveButtonWithUrlEvent(url: String) {
        
    }
    
    // MARK: - Training Tips
    
    func sendTrainingTipTappedToRootView(event: TrainingTipEvent) {
        getRootView().didReceiveTrainingTipTap(event: event)
    }
    
    func didReceiveTrainingTipTap(event: TrainingTipEvent) {
        
    }
    
    // MARK: - Errors
    
    func sendErrorToRootView(error: MobileContentErrorViewModel) {
        getRootView().didReceiveError(error: error)
    }
    
    func didReceiveError(error: MobileContentErrorViewModel) {
        
    }
    
    // MARK: - MobileContentStackChildViewType
    
    var view: UIView {
        return self
    }
    
    var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .constrainedToChildren
    }
}
