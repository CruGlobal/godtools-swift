//
//  MobileContentView.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentView: UIView {
        
    private(set) weak var parent: MobileContentView?
    
    private(set) var children: [MobileContentView] = Array()
    private(set) var visibilityState: MobileContentViewVisibilityState = .visible
            
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
    
    var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
    
    func setParentAndAddChild(childView: MobileContentView) {
    
        childView.parent = self
        
        children.append(childView)
    }
    
    func renderChild(childView: MobileContentView) {
        
        setParentAndAddChild(childView: childView)
    }
    
    func finishedRenderingChildren() {
        
    }
    
    func setVisibilityState(visibilityState: MobileContentViewVisibilityState) {
        
        guard self.visibilityState != visibilityState else {
            return
        }
        
        let previousVisibilityState: MobileContentViewVisibilityState = self.visibilityState
        
        self.visibilityState = visibilityState
        
        parent?.childViewDidChangeVisibilityState(
            childView: self,
            previousVisibilityState: previousVisibilityState,
            visibilityState: visibilityState
        )
    }
    
    func childViewDidChangeVisibilityState(childView: MobileContentView, previousVisibilityState: MobileContentViewVisibilityState, visibilityState: MobileContentViewVisibilityState) {
        
    }
    
    func removeAllChildren() {
        
        for child in children {
            child.removeFromSuperview()
        }
        
        children.removeAll()
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
    
    // MARK: - Position State
    
    func getPositionStateForViewHierarchy() -> MobileContentViewPositionState {
        
        let positionState: MobileContentViewPositionState = getPositionState()
        
        recurseHierarchyAndGetPositionState(view: self, viewPositionState: positionState)
        
        return positionState
    }
    
    private func recurseHierarchyAndGetPositionState(view: MobileContentView, viewPositionState: MobileContentViewPositionState) {
        
        for childView in view.children {
            
            let childPositionState: MobileContentViewPositionState = childView.getPositionState()
            
            viewPositionState.addChild(positionState: childPositionState)
            
            childView.recurseHierarchyAndGetPositionState(view: childView, viewPositionState: childPositionState)
        }
    }
    
    func getPositionState() -> MobileContentViewPositionState {
        
        return MobileContentViewPositionState()
    }
    
    private func setPositionStateForViewHierarchy(positionState: MobileContentViewPositionState, animated: Bool) {
        
        recurseHierarchyAndSetPositionState(view: self, viewPositionState: positionState, animated: animated)
    }
    
    private func recurseHierarchyAndSetPositionState(view: MobileContentView, viewPositionState: MobileContentViewPositionState, animated: Bool) {
        
        for index in 0 ..< viewPositionState.children.count {
            
            guard index < view.children.count else {
                continue
            }
            
            let childView: MobileContentView = view.children[index]
            let childPositionState: MobileContentViewPositionState = viewPositionState.children[index]
            
            childView.setPositionState(positionState: childPositionState, animated: animated)
            
            childView.recurseHierarchyAndSetPositionState(view: childView, viewPositionState: childPositionState, animated: animated)
        }
    }
    
    func setPositionState(positionState: MobileContentViewPositionState, animated: Bool) {
        
    }
}
