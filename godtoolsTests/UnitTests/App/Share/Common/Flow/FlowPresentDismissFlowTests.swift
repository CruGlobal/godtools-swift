//
//  FlowPresentDismissFlowTests.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Testing
import UIKit
@testable import godtools

@MainActor
struct FlowPresentDismissFlowTests: FlowTesting {
    
    @Test()
    func presentingAFlowIsMarkedAsPresented() {
        
        let rootFlow = getNewRootFlow()
        
        _ = getWindowAndAttachRootForPresentation(root: rootFlow.navigationController)
        
        let flow = getNewFlow()
                
        rootFlow.presentFlow(flow: flow, animated: false)
        
        #expect(flow.isPresented == true)
    }
    
    @Test()
    func presentingAFlowDoesNotShareTheNavigationControllerWithParent() {
        
        let rootFlow = getNewRootFlow()
        
        _ = getWindowAndAttachRootForPresentation(root: rootFlow.navigationController)
        
        let flow = getNewFlow()
                
        rootFlow.presentFlow(flow: flow, animated: false)
        
        #expect(rootFlow.navigationController != flow.navigationController)
    }
    
    @Test()
    func presentingAFlowPresentsTheFlowsNavigationControllerOnTheParent() {
        
        let rootFlow = getNewRootFlow()
        
        _ = getWindowAndAttachRootForPresentation(root: rootFlow.navigationController)
        
        let flow = getNewFlow(onPresentType: .presentNavigationController)
                        
        rootFlow.presentFlow(flow: flow, animated: false)
        
        #expect(rootFlow.navigationController.presentedViewController == flow.navigationController)
    }
    
    @Test()
    func presentingAFlowPresentsTheFlowsInitialViewOnTheParent() throws {
        
        let rootFlow = getNewRootFlow()
        
        _ = getWindowAndAttachRootForPresentation(root: rootFlow.navigationController)
        
        let flow = getNewFlow(onPresentType: .presentInitialView)
                        
        rootFlow.presentFlow(flow: flow, animated: false)
        
        let flowInitialView: UIViewController = try #require(flow.initialView)
        
        #expect(rootFlow.navigationController.presentedViewController == flowInitialView)
    }
    
    @Test()
    func presentingAFlowPresentsTheFlowsNavigationControllerOnTheParentAfterPushingTheSameFlow() {
        
        let rootFlow = getNewRootFlow()
        
        _ = getWindowAndAttachRootForPresentation(root: rootFlow.navigationController)
        
        let flow = getNewFlow()
        
        rootFlow.pushFlow(flow: flow, animated: false)
        
        rootFlow.popFlow(animated: false)
                
        rootFlow.presentFlow(flow: flow, animated: false)
        
        #expect(rootFlow.navigationController.presentedViewController == flow.navigationController)
    }
    
    @Test()
    func presentingAFlowPlacesTheInitialViewAtTheRootOfFlowsTheNavigationStack() {
        
        let rootFlow = getNewRootFlow()
        
        _ = getWindowAndAttachRootForPresentation(root: rootFlow.navigationController)
        
        let flow = getNewFlow()
                        
        rootFlow.presentFlow(flow: flow, animated: false)
        
        #expect(flow.navigationController.viewControllers.first == flow.initialView)
    }
    
    @Test()
    func cannotPresentAFlowWhileAFlowIsBeingPresented() {
        
        let rootFlow = getNewRootFlow()
        
        _ = getWindowAndAttachRootForPresentation(root: rootFlow.navigationController)
        
        let flowA = getNewFlow()
        
        let flowB = getNewFlow()
                
        rootFlow.presentFlow(flow: flowA, animated: true)
        
        #expect(rootFlow.isPresentingFlow == true)
        
        rootFlow.presentFlow(flow: flowB, animated: false)
        
        #expect(rootFlow.presentedFlow == flowA)
        
        #expect(flowA.presentedFlow == nil)
    }
    
    @Test()
    func dismissingAPresentedFlowIsNoLongerPresented() async throws {
        
        let rootFlow = getNewRootFlow()
        
        _ = getWindowAndAttachRootForPresentation(root: rootFlow.navigationController)
        
        let flow = getNewFlow()
                        
        rootFlow.presentFlow(flow: flow, animated: false)
        
        #expect(rootFlow.navigationController.presentedViewController == flow.navigationController)
        
        flow.parent?.dismissFlow(animated: false)
        
        try await Task.sleepHalfSecond()
        
        #expect(rootFlow.navigationController.presentedViewController == nil)
        #expect(rootFlow.navigationController.presentedViewController != flow.navigationController)
    }
    
    @Test()
    func presenterIsTheNavigationControllerWhenTheFlowIsPresentedWithNavigationControllerPresentType() {
        
        let rootFlow = getNewRootFlow()
        
        _ = getWindowAndAttachRootForPresentation(root: rootFlow.navigationController)
        
        let flow = getNewFlow(onPresentType: .presentNavigationController)
        
        rootFlow.presentFlow(flow: flow, animated: false)
        
        #expect(flow.presenter == flow.navigationController)
    }
    
    @Test()
    func presenterIsTheInitialViewControllerWhenTheFlowIsPresentedWithInitialViewControllerPresentType() {
        
        let rootFlow = getNewRootFlow()
        
        _ = getWindowAndAttachRootForPresentation(root: rootFlow.navigationController)
        
        let flow = getNewFlow(onPresentType: .presentInitialView)
                
        rootFlow.presentFlow(flow: flow, animated: false)
                
        #expect(flow.presenter == flow.initialView)
    }
    
    @Test()
    func theFlowsInitialViewForPresentationIsNilWhenTheFlowIsNotPresented() {
        
        let flow = getNewFlow(onPresentType: .presentInitialView)
        
        #expect(flow.initialViewForPresentedFlow == nil)
    }
    
    @Test()
    func theFlowsInitialViewForPresentationIsTheFlowsInitialView() {
        
        let rootFlow = getNewRootFlow()
        
        _ = getWindowAndAttachRootForPresentation(root: rootFlow.navigationController)
        
        let flow = getNewFlow(onPresentType: .presentInitialView)
        
        rootFlow.presentFlow(flow: flow, animated: false)
        
        #expect(flow.initialViewForPresentedFlow == flow.initialView)
    }
    
    @Test()
    func theFlowsInitialViewForPresentationIsTheFlowsNavigationController() {
        
        let rootFlow = getNewRootFlow()
        
        _ = getWindowAndAttachRootForPresentation(root: rootFlow.navigationController)
        
        let flow = getNewFlow(onPresentType: .presentNavigationController)
        
        rootFlow.presentFlow(flow: flow, animated: false)
        
        #expect(flow.initialViewForPresentedFlow == flow.navigationController)
    }
}
