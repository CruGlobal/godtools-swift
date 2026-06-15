//
//  Flow.swift
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
struct FlowTests: FlowTesting {
    
    @Test()
    func removesAllFlows() async throws {
        
        let rootFlow = getNewRootFlow()
        
        _ = getWindowAndAttachRootForPresentation(root: rootFlow.navigationController)
        
        let flowA = getNewFlow()
        
        let flowB = getNewFlow()
        
        let flowC = getNewFlow()
        
        let flowD = getNewFlow()
                
        rootFlow.pushFlow(flow: flowA, animated: false)
        flowA.pushFlow(flow: flowB, animated: false)
        flowB.presentFlow(flow: flowC, animated: false)
        flowC.presentFlow(flow: flowD, animated: false)
        
        #expect(rootFlow.pushedFlow != nil)
        #expect(flowA.pushedFlow != nil)
        #expect(flowB.presentedFlow != nil)
        #expect(flowC.presentedFlow != nil)
        
        rootFlow.removeAllFlows()
        
        #expect(rootFlow.pushedFlow == nil)
        #expect(flowA.pushedFlow == nil)
        #expect(flowB.presentedFlow == nil)
        #expect(flowC.presentedFlow == nil)
    }
    
    // MARK: - Mutate Navigation Controller
    
    @Test()
    func cannotMutateARootFlowsNavigationController() {
        
        let mainNavigationController = UINavigationController()
        
        let rootFlow = getNewRootFlow(navigationController: mainNavigationController)
        
        #expect(rootFlow.navigationController == mainNavigationController)
        
        let newNavigationController = UINavigationController()
        
        rootFlow.setNavigationController(navigationController: newNavigationController)
        
        #expect(rootFlow.navigationController == mainNavigationController)
    }
}
