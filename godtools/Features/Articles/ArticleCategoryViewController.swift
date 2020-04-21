//
//  ArticleCategoriesViewController.swift
//  godtools
//
//  Created by Igor Ostriz on 14/12/2018.
//  Copyright © 2018 Cru. All rights reserved.
//


import UIKit


class ArticleCategoryViewController: BaseViewController {

    
    static func create() -> ArticleCategoryViewController {
        let storyboard = UIStoryboard(name: Storyboard.articles, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "ArticleCategoryViewControllerID") as! ArticleCategoryViewController
    }
    
    @IBOutlet weak var spinnerView: UIView! {
        didSet {
            spinnerView.backgroundColor = UIColor.gtDimmedTranslucent
            spinnerView.alpha = 0.0
        }
    }
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView! {
        didSet {
            activityIndicatorView.color = UIColor.black
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            // eliminate extra separators
            tableView.tableFooterView = UIView()
        }
    }
    
    fileprivate var data: [ArticleData]?
    weak var category: XMLArticleCategory? {
        didSet {
            data = category?.data()
        }
    }
    var articlesPath: String?
    var resource: DownloadedResource?
    weak var articleManager: ArticleManager?
    
    var observingToken: NSObjectProtocol?
    
    deinit {
        NotificationCenter.default.removeObserver(observingToken as Any)
    }
    
    
    override var screenTitle: String
    {
        return category?.title ?? super.screenTitle
    }

    override func screenName() -> String {
        return "Category : \(screenTitle)"
    }
    override func siteSubSection() -> String {
        return "articles-list"
    }
    
    override func siteSection() -> String {
        return resource?.code ?? "article"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observingToken = NotificationCenter.default.addObserver(forName: .articleProcessingCompleted, object: nil, queue: OperationQueue.main) { (notification) in
            
            let articleID = notification.userInfo?["articleID"] as! String
            if self.articlesPath!.contains(articleID) {
                
                // give it a little slack (0.5 sec) to avoid flickering
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    
                    /*
                    if let c = self.articleManager?.categories.first(where: { (category) -> Bool in
                        return category.id() == self.category?.id()
                    }) {
                        self.category = c
                        self.reloadData()
                    }*/
                    
                }
            }
        }
        
        addDefaultNavBackItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }


    private func reloadData() {
        // hide spinner
        self.tableView.reloadData()
        spinnerView(on: false)
    }

    func spinnerView(on: Bool) {
        if on == true {
            spinnerView.alpha = 0.0
            view.bringSubviewToFront(spinnerView)
            activityIndicatorView.startAnimating()
        }
        UIView.animate(withDuration: 0.35, animations: {
            self.spinnerView.alpha = on ? 1.0 : 0.0
        }) { (finished) in
            if finished == true && on == false {
                self.view.sendSubviewToBack(self.spinnerView)
                self.activityIndicatorView.stopAnimating()
            }
        }
    }

}

//

extension ArticleCategoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleCategoryTableViewCell.cellID, for: indexPath) as! ArticleCategoryTableViewCell
        let articleData = data?[indexPath.row]
        
        cell.articleData = articleData
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (data?.count)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let articleData = data?[indexPath.row]
        presentWebArchive(articleData: articleData)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func presentWebArchive(articleData: ArticleData?) {
        
        let vc = ArticleWebViewController.create()
        vc.resource = resource
        vc.data = articleData
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
}
