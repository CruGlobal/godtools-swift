//
//  WebViewController.swift
//  godtools
//
//  Created by Pablo Marti on 6/5/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class WebViewController: BaseViewController {

    var pageTitleForAnalytics: String?
    var pageTitle: String?
    var websiteUrl: URL?
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.webView.loadRequest(URLRequest(url: websiteUrl!))
    }
    
    override var screenTitle: String {
        get {
            return self.pageTitle?.localized ?? ""
        }
    }
    
    // MARK: - Analytics
    
    override func screenName() -> String {
        return self.pageTitleForAnalytics ?? ""
    }

}
