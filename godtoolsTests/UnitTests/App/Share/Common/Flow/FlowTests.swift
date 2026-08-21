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
    func removesAllFlows() throws {
        
        let rootFlow = getNewRootFlow()
        
        let flowA = getNewFlow()
        
        let flowB = getNewFlow()
        
        let flowC = getNewFlow()
        
        let flowD = getNewFlow()
        
        _ = getWindowAndAttachRootForPresentation(root: rootFlow.navigationController)
        
        rootFlow.pushFlow(flow: flowA, animated: false)
        flowA.pushFlow(flow: flowB, animated: false)
        flowB.presentFlow(flow: flowC, animated: false)
        flowC.presentFlow(flow: flowD, animated: false)
        
        #expect(rootFlow.numberOfPushedFlows == 1)
        #expect(flowA.numberOfPushedFlows == 1)
        #expect(flowB.presentedFlow == flowC)
        #expect(flowC.presentedFlow == flowD)
        
        rootFlow.removeAllFlows()
        
        #expect(rootFlow.numberOfPushedFlows == 0)
        #expect(flowA.numberOfPushedFlows == 0)
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
