//
//  FlowToggleInitialViewTests.swift
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
struct FlowToggleInitialViewTests: FlowTesting {
    
    @Test()
    func presenterIsTheToggableInitialViewControllerWhenTheFlowIsPresentedWithInitialViewControllerPresentType() {
        
        let rootFlow = getNewRootFlow()
        
        _ = getWindowAndAttachRootForPresentation(root: rootFlow.navigationController)
        
        let flow = getNewFlow(onPresentType: .presentInitialView)
                
        rootFlow.presentFlow(flow: flow, animated: false)
        
        let toggleViewController = UIViewController()
        
        flow.toggleInitialView(view: toggleViewController, animated: false)
        
        let flowPresenter = flow.presenter
                
        #expect(flowPresenter == toggleViewController)
    }
    
    @Test()
    func presenterIsTheToggableInitialViewControllerWhenTheFlowIsPresentedWithNavigationControllerPresentType() {
        
        let rootFlow = getNewRootFlow()
        
        _ = getWindowAndAttachRootForPresentation(root: rootFlow.navigationController)
        
        let flow = getNewFlow(onPresentType: .presentNavigationController)
                
        rootFlow.presentFlow(flow: flow, animated: false)
        
        let toggleViewController = UIViewController()
        
        flow.toggleInitialView(view: toggleViewController, animated: false)
        
        let flowPresenter = flow.presenter
                
        #expect(flowPresenter == toggleViewController)
    }
    
    @Test()
    func togglingTheInitialViewOnAPushFlowsDoesNothing() {
        
        let rootFlow = getNewRootFlow()
        
        _ = getWindowAndAttachRootForPresentation(root: rootFlow.navigationController)
        
        let flow = getNewFlow()
                
        rootFlow.pushFlow(flow: flow, animated: false)
        
        let toggleViewController = UIViewController()
        
        flow.toggleInitialView(view: toggleViewController, animated: false)
                        
        #expect(flow.presenter == flow.navigationController)
        
        #expect(flow.presenter.presentedViewController == nil)
    }
    
    @Test()
    func presentingTheInitialViewOnAPushFlowsDoesNothing() {
        
        let rootFlow = getNewRootFlow()
        
        _ = getWindowAndAttachRootForPresentation(root: rootFlow.navigationController)
        
        let flow = getNewFlow()
                
        rootFlow.pushFlow(flow: flow, animated: false)
                
        flow.presentInitialView(animated: false)
                        
        #expect(flow.presenter == flow.navigationController)
        
        #expect(flow.presenter.presentedViewController == nil)
    }
    
    @Test()
    func presentsToggableViewAsInitialView() throws {
        
        let rootFlow = getNewRootFlow()
        
        _ = getWindowAndAttachRootForPresentation(root: rootFlow.navigationController)
        
        let flow = getNewFlow(onPresentType: .presentInitialView)
                
        rootFlow.presentFlow(flow: flow, animated: false)
        
        #expect(flow.presenter == flow.initialView)
                
        let toggleViewController = UIViewController()
        
        flow.toggleInitialView(view: toggleViewController, animated: false)
                                
        #expect(flow.presenter == toggleViewController)
    }
    
    @Test()
    func presentsInitialViewWhenToggableViewIsPresented() {
        
    }
    
    @Test()
    func presentsInitialViewWhenNoViewIsPresented() {
        
    }
}
