//
//  DownloadToolViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol DownloadToolViewModelType {
    
    var message: ObservableValue<String> { get }
    var isLoading: ObservableValue<Bool> { get }
    var downloadProgress: ObservableValue<Double> { get }
    var progressValue: ObservableValue<String> { get }
    
    func pageDidAppear()
    func closeTapped()
    func completeDownload(didCompleteDownload: @escaping (() -> Void))
}
