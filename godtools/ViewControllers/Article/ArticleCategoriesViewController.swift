//
//  ArticleCategoriesViewController.swift
//  godtools
//
//  Created by Igor Ostriz on 14/12/2018.
//  Copyright © 2018 Cru. All rights reserved.
//


import UIKit


class ArticleCategoriesViewController: BaseViewController {

    
    static func create() -> ArticleCategoriesViewController {
        let storyboard = UIStoryboard(name: Storyboard.articles, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "ArticleCategoriesViewControllerID") as! ArticleCategoriesViewController
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var data: [ArticleData]?
    var category: XMLArticleCategory?

    
    override var screenTitle: String
    {
        return category?.title ?? super.screenTitle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // eliminate extra separators
        tableView.tableFooterView = UIView()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    


}




//

extension ArticleCategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleCategoryTableViewCell.cellID, for: indexPath) as! ArticleCategoryTableViewCell
        let articleData = data?[indexPath.row]
        
        cell.articleData = articleData
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (data?.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
