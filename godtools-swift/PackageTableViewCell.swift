//
//  PackageTableCellView.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/31/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import UIKit

class PackageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var packageNameLabel: UILabel?
    
    func configureFrom(package: GodToolsPackage) {
        if (package.name != nil) {
            packageNameLabel?.text = package.name!
        } else {
            packageNameLabel?.text = package.code!
        }
        
        if (package.iconFilename != nil) {
            let image = loadImage(filename: package.iconFilename!)
            if (image != nil) {
                iconImageView?.image = loadImage(filename: package.iconFilename!)!
            }
        }
    }
    
    func loadImage (filename: String) -> UIImage? {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let fileURL = URL(fileURLWithPath: paths[0]).appendingPathComponent("GTFiles").appendingPathComponent(filename)
        
        do {
            let imageData = try Data.init(contentsOf: fileURL)
            return UIImage.init(data: imageData)
        } catch {
            return nil
        }
    }
}


