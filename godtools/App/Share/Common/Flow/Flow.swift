//
//  Flow.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import Combine

@MainActor
open class Flow: NSObject {
    
    private static let assertMessageForPresentInitialViewNotAllowed: String = "Presenting the initial view is only allowed on flows that have been presented."
    private static let assertMessageForDismissInitialViewNotAllowed: String = "Dismissing the initial view is only allowed on flows that have been presented."
    
    public static var defaultNavigationController: UINavigationController {
        return UINavigationController()
    }
    
    public static var defaultOnPresentType: OnPresentType {
        return .presentNavigationController
    }
    
    public enum OnPresentType {
        case presentInitialView
        case presentNavigationController
    }
     
    private let originalNavigationController: UINavigationController
    private let onPresentType: OnPresentType
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var toggableInitialViewForPresentedFlows: UIViewController?
    
    public private(set) var navigationController: UINavigationController
    public private(set) var pushedFlows: [Flow] = Array()
    public private(set) var presentedFlow: Flow?
    private(set) var presentedView: UIViewController?
    
    public private(set) weak var parent: Flow?
    
    public let stepEmitter: FlowStepEmitter
    public let initialView: UIViewController?
    
    public init(
        initialView: UIViewController?,
        stepEmitter: FlowStepEmitter,
        navigationController: UINavigationController = Flow.defaultNavigationController,
        onPresentType: OnPresentType = Flow.defaultOnPresentType
    ) {
                        
        self.originalNavigationController = navigationController
        self.initialView = initialView
        self.stepEmitter = stepEmitter
        self.navigationController = navigationController
        self.onPresentType = onPresentType
        
        super.init()
                
        stepEmitter.publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (step: FlowStep) in
                self?.navigate(step: step)
            }
            .store(in: &cancellables)
    }
    
    public var isPresented: Bool {
        return parent?.presentedFlow == self
    }
    
    public var nearestNavigationControllerInHierarchy: UINavigationController {
        
        var parent: Flow = self
        
        while parent.isPresented {
            if let nextParent = parent.parent {
                parent = nextParent
            }
            else {
                return parent.navigationController
            }
        }
        
        return parent.navigationController
    }
    
    open func printWarning(message: String) {
        print("Flow.swift ** WARNING ** \(message)")
    }
    
    open func navigate(step: FlowStep) {
        
    }
    
    open func onAddedToParent() {
        
    }
    
    open func onPushed(animated: Bool) {
        
    }
    
    open func onPopped(animated: Bool) {
        
    }
    
    open func onPresented(animated: Bool) {
        
    }
    
    open func onDismissed(animated: Bool) {
        
    }
    
    public func removeAllFlows() {
        recurseAndRemoveAllFlows(flow: self)
    }
    
    private func recurseAndRemoveAllFlows(flow: Flow) {
            
        for pushedFlow in flow.pushedFlows {
            recurseAndRemoveAllFlows(flow: pushedFlow)
        }
        
        var topMostPresentedFlow: Flow? = flow.getTopMostPresentedFlow()
        
        while topMostPresentedFlow != nil && topMostPresentedFlow != flow {
            
            if let flow = topMostPresentedFlow {
                recurseAndRemoveAllFlows(flow: flow)
            }
            
            topMostPresentedFlow = topMostPresentedFlow?.parent
        }
        
        flow.removeAllPushedFlows()
        flow.presentedFlow = nil
    }
    
    public func setParent(parent: Flow?) {
        
        self.parent = parent
        
        if parent != nil {
            onAddedToParent()
        }
    }
    
    private func canAddFlow(flow: Flow) -> Bool {
        
        let flowIsEqualToSelf: Bool = flow == self
        let flowIsRoot: Bool = flow is RootFlow
        let flowHasParent: Bool = flow.parent != nil
        let flowIsPushed: Bool = pushedFlows.contains(flow)
        let flowIsPresented: Bool = flow == presentedFlow
        
        guard !flowIsEqualToSelf && !flowIsRoot && !flowHasParent && !flowIsPushed && !flowIsPresented else {
            return false
        }
        
        return true
    }
    
    // MARK: - Push / Pop Flow
    
    public var numberOfPushedFlows: Int {
        return pushedFlows.count
    }
    
    public func setNavigationController(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    private func resetNavigationController() {
        navigationController = originalNavigationController
    }
    
    public func pushFlow(flow: Flow, animated: Bool = true) {
        
        guard canAddFlow(flow: flow) else {
            printWarning(message: "Cannot push flow: \(flow)")
            return
        }
        
        flow.setParent(parent: self)
                
        pushedFlows.append(flow)
        
        flow.setNavigationController(navigationController: navigationController)
        
        if let flowInitialView = flow.initialView {
            navigationController.pushViewController(flowInitialView, animated: animated)
        }
        
        flow.onPushed(animated: animated)
    }
    
    public func popFlow(animated: Bool = true, popToViewController: UIViewController? = nil) {
        
        guard let topFlow = pushedFlows.last else {
            return
        }
        
        guard let index = pushedFlows.firstIndex(of: topFlow) else {
            return
        }
        
        pushedFlows.remove(at: index)
        
        if let viewController = popToViewController, navigationController.viewControllers.contains(viewController) {
            
            navigationController.popToViewController(
                viewController,
                animated: animated
            )
        }
        else if topFlow.initialView != nil {
            
            navigationController.popViewController(
                animated: animated
            )
        }
        
        topFlow.onPopped(animated: animated)
        
        topFlow.resetNavigationController()
        
        topFlow.parent = nil
    }
    
    private func removeAllPushedFlows() {
        
        guard !pushedFlows.isEmpty else {
            return
        }
        
        let count: Int = pushedFlows.count
        
        for index in stride(from: count - 1, through: 0, by: -1) {
            
            let flow: Flow = pushedFlows[index]
            
            pushedFlows.remove(at: index)
            
            flow.parent = nil
            
            flow.resetNavigationController()
        }
    }
    
    // MARK: - Present / Dismiss Flow
    
    public var presenter: UIViewController {
        
        if isPresented {
            
            if let toggableInitialViewForPresentedFlows = toggableInitialViewForPresentedFlows {
                return toggableInitialViewForPresentedFlows
            }
            
            switch onPresentType {
            
            case .presentInitialView:
                
                if let initialView = initialView, initialView.presentingViewController != nil {
                    return initialView
                }
                
                return  nearestNavigationControllerInHierarchy
            
            case .presentNavigationController:
                return navigationController
            }
        }
        
        return navigationController
    }
    
    public var isPresentingFlow: Bool {
        
        guard let presentedFlow = self.presentedFlow else {
            return false
        }
        
        return getFlowViewToPresent(flow: presentedFlow)?.isBeingPresented ?? false
    }
    
    public func getTopMostPresentedFlow() -> Flow? {
        
        var topFlow: Flow? = presentedFlow
        var nextPresentedFlow: Flow? = topFlow?.presentedFlow
        
        while nextPresentedFlow != nil {
            topFlow = nextPresentedFlow
            nextPresentedFlow = nextPresentedFlow?.presentedFlow
        }
        
        return topFlow
    }
    
    private func getFlowViewToPresent(flow: Flow) -> UIViewController? {
       
        guard let flowInitialView = flow.initialView else {
            return nil
        }
        
        switch flow.onPresentType {
        
        case .presentInitialView:
            return flowInitialView
        
        case .presentNavigationController:
            return flow.navigationController
        }
    }
    
    public func presentFlow(flow: Flow, animated: Bool = true) {
        
        guard presentedFlow == nil else {
            printWarning(message: "Cannot present flow: \(flow) because a flow \(String(describing: presentedFlow)) is already presented")
            return
        }
        
        guard !isPresentingFlow else {
            printWarning(message: "Cannot present flow \(flow) because a flow is currently being presented \(String(describing: presentedFlow)).")
            return
        }
        
        guard canAddFlow(flow: flow) else {
            printWarning(message: "Cannot present flow \(flow). Failed to add flow.")
            return
        }
        
        presentedFlow = flow
        
        flow.setParent(parent: self)
        
        if let flowInitialView = flow.initialView {
                        
            let viewToPresent: UIViewController
            
            switch flow.onPresentType {
            case .presentInitialView:
                viewToPresent = flowInitialView
            case .presentNavigationController:
                flow.navigationController.setViewControllers([flowInitialView], animated: false)
                viewToPresent = flow.navigationController
            }
            
            presenter.present(
                viewToPresent,
                animated: animated
            )
        }
        
        flow.onPresented(animated: animated)
    }
    
    public func dismissFlow(animated: Bool = true, completion: (() -> Void)? = nil) {
        
        guard let topFlow = presentedFlow else {
            completion?()
            return
        }
        
        let controllerToDismiss: UIViewController?
        
        switch topFlow.onPresentType {
        case .presentInitialView:
            controllerToDismiss = topFlow.initialView
        case .presentNavigationController:
            controllerToDismiss = topFlow.navigationController
        }
        
        if let controllerToDismiss = controllerToDismiss {
            
            controllerToDismiss.dismissWithCompletion(
                animated: animated,
                completion: completion
            )
        }
        else {
            
            completion?()
        }
                
        topFlow.onDismissed(animated: animated)
        
        topFlow.parent = nil
        
        presentedFlow = nil
    }
}

// MARK: - Push / Present View

extension Flow {
    
    public var isPresentingView: Bool {
        
        guard let presentedView = presentedView else {
            return false
        }
        
        return presentedView.isBeingPresented
    }
    
    public func presentView(view: UIViewController, animated: Bool, completion: (() -> Void)? = nil, shouldTogglePresentedView: Bool = true) {
        
        guard !isPresentingView else {
            printWarning(message: "Cannot present view \(view) because a view is currently being presented \(String(describing: presentedView)).")
            return
        }
        
        let isPresentable: Bool = presentedView == nil || shouldTogglePresentedView
        
        guard isPresentable else {
            printWarning(message: "Cannot present view \(view) because a view is already presented \(String(describing: presentedView)).")
            return
        }
        
        let presentOnView: UIViewController = presenter
        
        if shouldTogglePresentedView {
            
            dismissView(animated: animated, completion: { [weak self] in
            
                self?.presentedView = view
                
                presentOnView
                    .present(
                        view,
                        animated: animated,
                        completion: completion
                    )
            })
        }
        else {
            
            presentedView = view
            
            presentOnView
                .present(
                    view,
                    animated: animated,
                    completion: completion
                )
        }
    }
    
    public func dismissView(animated: Bool, completion: (() -> Void)? = nil) {
        
        guard let presentedView = self.presentedView else {
            completion?()
            return
        }
        
        presentedView.dismissWithCompletion(animated: animated, completion: { [weak self] in
            
            self?.presentedView = nil
            completion?()
        })
    }
    
    public func pushView(view: UIViewController, animated: Bool) {
        
        if isPresented {
            
            switch onPresentType {
            
            case .presentInitialView:
                printWarning(message: "Failed to push view: \(view).  Cannot push a view on a presented flows initial view.")
            
            case .presentNavigationController:
                navigationController.pushViewController(view, animated: animated)
            }
        }
        else {
            
            navigationController.pushViewController(view, animated: animated)
        }
    }
}

// MARK: - Toggle Initial View

extension Flow {
    
    public var initialViewForPresentedFlow: UIViewController? {
        
        guard isPresented else {
            return nil
        }
        
        switch onPresentType {
        case .presentInitialView:
            return initialView
        case .presentNavigationController:
            return navigationController
        }
    }
    
    public func toggleInitialView(view: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        
        guard isPresented else {
            printWarning(message: Self.assertMessageForPresentInitialViewNotAllowed)
            return
        }
        
        dismissInitialView(animated: animated, completion: { [weak self] in
            
            self?.toggableInitialViewForPresentedFlows = view
            
            UIViewController.presentViewIfNotPresented(
                viewController: view,
                presentOn: self?.parent?.presenter,
                animated: animated,
                completion: completion
            )
        })
    }
    
    public func presentInitialView(animated: Bool, completion: (() -> Void)? = nil) {
        
        guard isPresented else {
            printWarning(message: Self.assertMessageForPresentInitialViewNotAllowed)
            return
        }
        
        UIViewController.dismissViewIfPresented(
            viewController: toggableInitialViewForPresentedFlows,
            animated: animated,
            completion: { [weak self] in
                
                UIViewController.presentViewIfNotPresented(
                    viewController: self?.initialViewForPresentedFlow,
                    presentOn: self?.parent?.presenter,
                    animated: animated,
                    completion: completion
                )
            }
        )
    }
    
    public func dismissInitialView(animated: Bool, completion: (() -> Void)? = nil) {

        guard isPresented else {
            printWarning(message: Self.assertMessageForDismissInitialViewNotAllowed)
            return
        }
        
        let viewControllerToDismiss: UIViewController? = toggableInitialViewForPresentedFlows ?? initialViewForPresentedFlow
        
        UIViewController.dismissViewIfPresented(
            viewController: viewControllerToDismiss,
            animated: animated,
            completion: { [weak self] in
                
                self?.toggableInitialViewForPresentedFlows = nil
                
                completion?()
            }
        )
    }
}
