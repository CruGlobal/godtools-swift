
//
//  TractViewControllerPageMovements.swift
//  godtools
//
//  Created by Devserker on 5/30/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

extension TractViewController {
    
    func moveToPage(notification: Notification) {
        guard let dictionary = notification.userInfo as? [String: String] else {
            return
        }
        
        guard let pageListener = dictionary["pageListener"] else { return }
        guard let page = TractBindings.pageBindings[pageListener] else { return }
        
        self.currentPage = page
        _ = reloadPagesViews()
        _ = moveViews()
    }
    
    func moveToNextPage() {
        if self.currentPage >= totalPages() - 1 {
            return
        }
        
        _ = self.moveForewards()
            .then { (success) -> Promise<Bool> in
                if success {
                    _ = self.reloadPagesViews()
                    return Promise(value: true)
                }
                return Promise(value: false)
        }
    }
    
    func moveToPreviousPage() {
        if self.currentPage == 0 {
            return
        }
        
        _ = self.moveBackwards()
            .then { (success) -> Promise<Bool> in
                if success == true {
                    _ = self.reloadPagesViews()
                    return Promise(value: true)
                }
                return Promise(value: false)
        }
    }
    
    func removeViewsBeforeCurrentView() {
        if self.currentPage == 0 {
            return
        }
        
        let currentPageView = self.view.viewWithTag(self.currentPage + self.viewTagOrigin)
        
        for pageView in self.pagesViews {
            if pageView == currentPageView {
                break
            }
            pageView?.removeFromSuperview()
        }
    }
    
    // MARK: - Promises
    
    fileprivate func moveViews() -> Promise<Bool> {
        let newCurrentProgressViewFrame = buildProgressViewFrame()
        return UIView.promise(animateWithDuration: 0.35, delay: 0.0, options: .curveEaseInOut, animations: { 
            self.currentProgressView.frame = newCurrentProgressViewFrame
            for view in self.pagesViews {
                view?.transform = CGAffineTransform(translationX: self.currentMovement, y: 0.0)
            }
        }).then { _ in
            self.notifyCurrentViewDidAppearOnTract()
            return Promise(value: true)
        }
    }
    
    fileprivate func moveForewards() -> Promise<Bool> {
        self.currentPage += 1
        let newCurrentProgressViewFrame = buildProgressViewFrame()
        guard let currentPageView = self.view.viewWithTag(self.currentPage + self.viewTagOrigin) else {
            return Promise(value: false)
        }
        
        return UIView.promise(animateWithDuration: 0.35, delay: 0.0, options: .curveEaseInOut, animations: {
            self.currentProgressView.frame = newCurrentProgressViewFrame
            currentPageView.transform = CGAffineTransform(translationX: self.currentMovement, y: 0.0)
        }).then { _ in
            self.moveViewsExceptCurrentViews(pageViews: [currentPageView])
            return Promise(value: true)
        }
    }
    
    fileprivate func moveBackwards() -> Promise<Bool> {
        self.currentPage -= 1
        let newCurrentProgressViewFrame = buildProgressViewFrame()
        guard let currentPageView = self.view.viewWithTag(self.currentPage + self.viewTagOrigin) else {
            return Promise(value: false)
        }
        guard let nextPageView = self.view.viewWithTag(self.currentPage + 1 + self.viewTagOrigin) else {
            return Promise(value: false)
        }
        
        currentPageView.transform = CGAffineTransform(translationX: self.currentMovement, y: 0.0)
        return UIView.promise(animateWithDuration: 0.35, delay: 0.0, options: .curveEaseInOut, animations: {
            self.currentProgressView.frame = newCurrentProgressViewFrame
            nextPageView.transform = CGAffineTransform(translationX: self.currentMovement, y: 0.0)
        }).then { _ in
            self.moveViewsExceptCurrentViews(pageViews: [currentPageView, nextPageView])
            return Promise(value: true)
        }
    }
    
    fileprivate func moveViewsExceptCurrentViews(pageViews: [UIView]) {
        for view in self.pagesViews {
            if view == nil || pageViews.index(of: view!) != nil {
                continue
            }
            
            view?.transform = CGAffineTransform(translationX: self.currentMovement, y: 0.0)
        }
        self.notifyCurrentViewDidAppearOnTract()
    }
    
    fileprivate func notifyCurrentViewDidAppearOnTract() {
        let currentTractView = self.view.viewWithTag(self.currentPage + self.viewTagOrigin) as? TractView
        currentTractView?.contentView?.notifyViewDidAppearOnTract()
    }
    
    // MARK: - Helpers
    
    fileprivate func buildProgressViewFrame() -> CGRect {
        return CGRect(x: 0.0,
                      y: 0.0,
                      width: currentProgressWidth(),
                      height: self.currentProgressView.frame.size.height)
    }
}
