//
//  ArticleViewController.swift
//  godtools
//
//  Created by Igor Ostriz on 13/11/2018.
//  Copyright © 2018 Cru. All rights reserved.
//

import UIKit

class ArticleViewController: BaseViewController {

    var resource: DownloadedResource?
    
    static func create() -> ArticleViewController {
        return ArticleViewController(nibName: String(describing: ArticleViewController.self), bundle: nil) as ArticleViewController
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
