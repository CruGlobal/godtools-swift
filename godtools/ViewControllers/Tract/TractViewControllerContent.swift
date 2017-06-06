//
//  TractViewControllerContent.swift
//  godtools
//
//  Created by Devserker on 5/30/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractViewController {
    
    static let snapshotViewTag = 3210123
    
    func buildPages(width: CGFloat, height: CGFloat) {
        cleanContainerView()
        
        let range = getRangeOfViews()
        for pageNumber in range.start...range.end {
            let view = buildPage(pageNumber, width: width, height: height)
            self.pagesViews[pageNumber] = view
            self.containerView.addSubview(view)
        }
        
        removeSnapshotView()
    }
    
    func buildPage(_ pageNumber: Int, width: CGFloat, height: CGFloat) -> BaseTractView {
        let xPosition = (width * CGFloat(pageNumber))
        let frame = CGRect(x: xPosition,
                           y: 0.0,
                           width: width,
                           height: height)
        
        let page = getPage(pageNumber)
        let configurations = TractConfigurations()
        configurations.defaultTextAlignment = getLanguageTextAlignment()
        configurations.pagination = page.pagination
        
        let view = BaseTractView(frame: frame, data: page.pageContent(), colors: self.colors!, configurations: configurations)
        view.transform = CGAffineTransform(translationX: self.currentMovement, y: 0.0)
        view.tag = self.viewTagOrigin + pageNumber
        
        return view
    }
    
    func reloadPagesViews() {
        let range = getRangeOfViews()
        let width = self.containerView.frame.size.width
        let height = self.containerView.frame.size.height
        let lastPosition = self.totalPages() - 1
        var tmpPagesViews = [BaseTractView?](repeating: nil, count: 10)
        
        for position in range.start...range.end {
            let pageView = self.pagesViews[position]
            if pageView != nil {
                tmpPagesViews[position] = pageView!
            } else {
                let view = buildPage(position, width: width, height: height)
                tmpPagesViews[position] = view
                self.containerView.addSubview(view)
            }
        }
        
        for position in 0...lastPosition {
            let pageView = self.pagesViews[position]
            if pageView != nil && (position < range.start || position > range.end) {
                pageView?.removeFromSuperview()
            }
        }
        
        self.pagesViews = tmpPagesViews
    }
    
    func getRangeOfViews() -> (start: Int, end: Int) {
        var start = self.currentPage - 2
        if start < 0 {
            start = 0
        }
        
        var end = self.currentPage + 2
        if end >= self.totalPages() {
            end = totalPages() - 1
        }
        
        return (start, end)
    }
    
    func cleanContainerView() {
        addSnapshotView()
        
        for view in self.containerView.subviews {
            if view.tag != TractViewController.snapshotViewTag {
                view.removeFromSuperview()
            }
        }
        
        self.pagesViews.removeAll()
        resetPagesView()
    }
    
    func resetPagesView() {
        self.pagesViews = [BaseTractView?](repeating: nil, count: 10)
    }
    
    private func addSnapshotView() {
        let imageView = UIImageView(frame: self.containerView.frame)
        imageView.image = UIImage.init(view: self.containerView)
        imageView.tag = TractViewController.snapshotViewTag
        self.containerView.addSubview(imageView)
    }
    
    private func removeSnapshotView() {
        let snapshotView = self.containerView.viewWithTag(TractViewController.snapshotViewTag)
        snapshotView?.removeFromSuperview()
    }
    
}
