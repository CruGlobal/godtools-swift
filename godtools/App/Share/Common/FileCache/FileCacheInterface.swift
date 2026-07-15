//
//  FileCacheInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

protocol FileCacheInterface {
    
    var rootDirectory: URL { get }
    
    func getIsDirectory(url: URL) -> Bool
    func getUserDocumentsDirectory() throws -> URL
    func getDirectory(location: FileCacheLocation) -> URL
    func createDirectoryIfNotExists(directoryUrl: URL) throws -> URL
    func getFileExists(location: FileCacheLocation) throws -> Bool
    func getFile(location: FileCacheLocation) throws -> URL
    func getData(location: FileCacheLocation) throws -> Data?
    func getUIImage(location: FileCacheLocation) throws -> UIImage?
    func getImage(location: FileCacheLocation) throws -> Image?
    func storeFile(location: FileCacheLocation, data: Data) throws -> URL
    func removeRootDirectory() throws
    func removeFile(location: FileCacheLocation) throws
    func removeItem(url: URL) throws
    func moveContentsOfDirectory(directory: URL, toDirectory: URL) throws
    func moveChildDirectoryContentsIntoParent(parentDirectory: URL) throws
}
