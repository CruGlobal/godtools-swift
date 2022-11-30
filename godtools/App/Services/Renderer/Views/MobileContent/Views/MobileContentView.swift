//
//  MobileContentView.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentView: UIView {
            
    enum EventTriggerType {
        
        case recursivelyFromRootView
        case walkingUpViewHierarchy
    }
    
    private(set) weak var parent: MobileContentView?
    
    private(set) var children: [MobileContentView] = Array()
    private(set) var visibilityState: MobileContentViewVisibilityState = .visible
    private(set) var drawsShadow: Bool = false
    
    var paddingInsets: UIEdgeInsets {
        return .zero
    }
            
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
    
    // MARK: - Shadow
    
    func drawShadow(shadowOffset: CGSize = CGSize(width: 1, height: 1), shadowRadius: CGFloat = 3, shadowOpacity: Float = 0.3) {
        
        drawsShadow = true
        
        layer.shadowOffset = shadowOffset
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
    }
    
    // MARK: - Events
    
    func sendEventsToAllViews(eventIds: [EventId], rendererState: State) {
            
        var eventIds: [EventId] = eventIds.flatMap({$0.resolve(state: rendererState)})
                
        walkUpHierarchyAndSendEventsToEachAncestor(view: self, eventIds: &eventIds)
                
        recurseChildrenAndSendEventsFromView(view: getRootView(), eventIds: &eventIds, eventTrigger: .recursivelyFromRootView)
    }
    
    private func walkUpHierarchyAndSendEventsToEachAncestor(view: MobileContentView, eventIds: inout [EventId]) {
        
        guard let parent = view.parent, !eventIds.isEmpty else {
            return
        }
        
        sendEventsToView(view: parent, eventIds: &eventIds, eventTrigger: .walkingUpViewHierarchy)
        
        walkUpHierarchyAndSendEventsToEachAncestor(view: parent, eventIds: &eventIds)
    }
    
    private func recurseChildrenAndSendEventsFromView(view: MobileContentView, eventIds: inout [EventId], eventTrigger: EventTriggerType) {
        
        guard !eventIds.isEmpty else {
            return
        }
        
        for childView in view.children {
            recurseChildrenAndSendEventsFromView(view: childView, eventIds: &eventIds, eventTrigger: eventTrigger)
        }
        
        sendEventsToView(view: view, eventIds: &eventIds, eventTrigger: eventTrigger)
    }
    
    private func sendEventsToView(view: MobileContentView, eventIds: inout [EventId], eventTrigger: EventTriggerType) {

        guard !eventIds.isEmpty else {
            return
        }
        
        for index in stride(from: eventIds.count - 1, through: 0, by: -1) {
            
            let eventId: EventId = eventIds[index]
            
            let processedEventResult: ProcessedEventResult?
            
            switch eventTrigger {
            case .recursivelyFromRootView:
                processedEventResult = view.didReceiveEvent(eventId: eventId, eventIdsGroup: eventIds)
            case .walkingUpViewHierarchy:
                processedEventResult = view.didReceiveAncestryEventFromWalkingUpViewHierarchy(eventId: eventId, eventIdsGroup: eventIds)
            }
            
            guard let processedEventResult = processedEventResult else {
                continue
            }
            
            if processedEventResult.shouldRemoveEventId {
                removeEventIdFromEventIds(eventIds: &eventIds, eventIdToRemove: eventId)
            }
        }
    }
    
    private func removeEventIdFromEventIds(eventIds: inout [EventId], eventIdToRemove: EventId) {
        if let index = eventIds.firstIndex(of: eventIdToRemove) {
            eventIds.remove(at: index)
        }
    }
    
    func didReceiveEvent(eventId: EventId, eventIdsGroup: [EventId]) -> ProcessedEventResult? {
        
        return nil
    }
    
    func didReceiveAncestryEventFromWalkingUpViewHierarchy(eventId: EventId, eventIdsGroup: [EventId]) -> ProcessedEventResult? {
        
        return nil
    }
    
    // MARK: - Url Events
    
    func sendButtonWithUrlEventToRootView(url: URL) {
        getRootView().didReceiveButtonWithUrlEvent(url: url)
    }
    
    func didReceiveButtonWithUrlEvent(url: URL) {
        
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
        
        let rootPositionState: MobileContentViewPositionState = getPositionState()
        
        recurseHierarchyAndGetPositionState(view: self, viewPositionState: rootPositionState)
        
        return rootPositionState
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
    
    func setPositionStateForViewHierarchy(positionState: MobileContentViewPositionState, animated: Bool) {
        
        setPositionState(positionState: positionState, animated: animated)
        
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
