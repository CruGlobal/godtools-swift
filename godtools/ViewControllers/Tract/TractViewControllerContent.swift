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
            self.pagesViews.append(view)
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
        
        let view = BaseTractView(frame: frame, data: page.pageContent(), colors: self.colors!, configurations: configurations)
        view.transform = CGAffineTransform(translationX: self.currentMovement, y: 0.0)
        view.tag = self.viewTagOrigin + pageNumber
        
        return view
    }
    
    func reloadPagesViews() {
        let range = getRangeOfViews()
        let firstTag = (self.pagesViews.first?.tag)! - self.viewTagOrigin
        let lastTag = (self.pagesViews.last?.tag)! - self.viewTagOrigin
        let width = self.containerView.frame.size.width
        let height = self.containerView.frame.size.height
        
        if firstTag < range.start {
            for _ in 0...firstTag {
                self.pagesViews.first?.removeFromSuperview()
                self.pagesViews.removeFirst()
            }
            
        } else if firstTag > range.start {
            var position = 0
            for _ in range.start...firstTag {
                let view = buildPage(range.start + position, width: width, height: height)
                self.pagesViews.insert(view, at: position)
                self.containerView.addSubview(view)
                position += 1
            }
        }
        
        if lastTag < range.end {
            for position in lastTag...range.end {
                let view = buildPage(position, width: width, height: height)
                self.pagesViews.append(view)
                self.containerView.addSubview(view)
            }
        } else if lastTag > range.end {
            for _ in range.end...lastTag {
                self.pagesViews.last?.removeFromSuperview()
                self.pagesViews.removeLast()
            }
        }
    }
    
    func getRangeOfViews() -> (start: Int, end: Int) {
        var start = self.currentPage - 2
        if start < 0 {
            start = 0
        }
        
        var end = self.currentPage + 2
        if end > self.totalPages() - 1 {
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
