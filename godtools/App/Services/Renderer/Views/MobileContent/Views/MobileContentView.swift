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
    
    // MARK: - View Did Appear
    
    func notifyViewAndAllChildrenViewDidAppear() {
        recurseViewDidAppear(view: self)
    }
    
    private func recurseViewDidAppear(view: MobileContentView) {
        for childView in view.children {
            recurseViewDidAppear(view: childView)
        }
        view.viewDidAppear()
    }
    
    func viewDidAppear() {
        // NOTE: Subclasses should override and do anything here on view did appear.
    }
    
    // MARK: - View Did Disappear
    
    func notifyViewAndAllChildrenViewDidDisappear() {
        recurseViewDidDisappear(view: self)
    }
    
    private func recurseViewDidDisappear(view: MobileContentView) {
        for childView in view.children {
            recurseViewDidDisappear(view: childView)
        }
        view.viewDidDisappear()
    }
    
    func viewDidDisappear() {
        // NOTE: Subclasses should override and do any clean up here on view did disappear.
    }
    
    // MARK: - Events
    
    func sendEventsToAllViews(eventIds: [MultiplatformEventId], rendererState: MobileContentMultiplatformState) {
        
        let eventIds: [MultiplatformEventId] = eventIds.flatMap({$0.resolve(rendererState: rendererState)})
        
        recurseChildrenAndSendEvents(view: getRootView(), eventIds: eventIds)
    }
    
    private func recurseChildrenAndSendEvents(view: MobileContentView, eventIds: [MultiplatformEventId]) {
        
        for childView in view.children {
            recurseChildrenAndSendEvents(view: childView, eventIds: eventIds)
        }
        
        view.didReceiveEvents(eventIds: eventIds)
    }
    
    func didReceiveEvents(eventIds: [MultiplatformEventId]) {
        
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
