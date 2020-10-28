//
//  PageXmlNodeRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class PageXmlNodeRenderer {
    
    private let parser: PageXmlNodeParser = PageXmlNodeParser()
    
    required init() {
        
    }
    
    func renderPageXml(pageXml: Data) {
        
    }
    
    func renderPageXmlElement(pageXmlElement: XMLElement) -> PageNode? {
        
        return parser.parsePageXmlElement(
            pageXmlElement: pageXmlElement,
            delegate: self
        )
    }
    
    func renderPageNode(page: PageNode) -> UIView {
        
        let pageNodeView = PageNodeView(pageNode: page)
        
        return pageNodeView.view
    }
    
    private func recurseAndRenderNode(node: RendererXmlNode) -> UIView {
        
        let nodeView: UIView = getNodeView(node: node)
        
        for childNode in node.children {
            
            let childView: UIView = recurseAndRenderNode(node: childNode)
            
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
        view.frame = CGRect(x: 0, y: 0, width: 414, height: 50)
        view.backgroundColor = .green
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.blue.cgColor
        
        return view
    }
}

// MARK: - PageXmlNodeParserDelegate

extension PageXmlNodeRenderer: PageXmlNodeParserDelegate {
    
    func pageXmlNodeParserDidParseNode(parser: PageXmlNodeParser, node: RendererXmlNode, nodeParent: RendererXmlNode?) {
        
        print("\n PageXmlNodeRenderer: pageXmlNodeParserDidParseNode()")
        print("  node: \(node.type)")
        print("  node parent: \(nodeParent?.type)")
    }
}
