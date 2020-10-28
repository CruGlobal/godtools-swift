//
//  PageNodeView.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class PageNodeView: UIViewController {
    
    private let pageNode: PageNode
    
    @IBOutlet weak private var backgroundImageView: UIImageView!
    @IBOutlet weak private var contentScrollView: UIScrollView!
    
    required init(pageNode: PageNode) {
        self.pageNode = pageNode
        super.init(nibName: String(describing: PageNodeView.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
        
        renderPageNodeIntoView(pageNode: pageNode)
        
        setupLayout()
        setupBinding()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
    }
    
    private func renderPageNodeIntoView(pageNode: PageNode) {
        
        contentScrollView.backgroundColor = .magenta
        contentScrollView.alpha = 1
        contentScrollView.contentSize = UIScreen.main.bounds.size
        
        for childNode in pageNode.children {
            
            let view: UIView = recurseAndRenderNode(node: childNode)
            
            contentScrollView.addSubview(view)
            
            view.backgroundColor = .red
        }
    }
    
    private func recurseAndRenderNode(node: RendererXmlNode) -> UIView {
        
        let nodeView: UIView = getNodeView(node: node)
        
        var prevFrame: CGRect = .zero
        
        for childNode in node.children {
            
            let childView: UIView = recurseAndRenderNode(node: childNode)
            
            //var frame: CGRect = childView.frame
            //frame.origin.y = prevFrame.origin.y + prevFrame.size.height
            //childView.frame = frame
            
            //prevFrame = childView.frame
            
            nodeView.addSubview(childView)
        }
        
        // update nodeView bounds to match children.
        
        return nodeView
    }
    
    private func getNodeView(node: RendererXmlNode) -> UIView {
        
        switch node.type {
            
        case .contentParagraph:
            break
            
        case .contentText:
            break
            
        case .contentImage:
            break
            
        case .page:
            break
        }
        
        let view: UIView = UIView()
        view.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 50)
        view.alpha = 0.4
        view.backgroundColor = .green
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.blue.cgColor
        
        return view
    }
}
