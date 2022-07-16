//
//  FileCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

class FileCache {
    
    let fileManager: FileManager = FileManager.default
    let rootDirectory: String
    let errorDomain: String
    
    required init(rootDirectory: String) {
        self.rootDirectory = rootDirectory
        self.errorDomain = "\(type(of: self))"
    }
    
    func getIsDirectory(url: URL) -> Bool {
        
        var isDirectory: ObjCBool = false
        
        if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory){
            return isDirectory.boolValue
        }
        
        return false
    }
    
    func getUserDocumentsDirectory() -> Result<URL, Error> {
        
        do {
            let documentsDirectory: URL = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            return .success(documentsDirectory)
        }
        catch let error {
            return .failure(error)
        }
    }
    
    func getRootDirectory() -> Result<URL, Error> {
    
        switch getUserDocumentsDirectory() {
        case .success(let documentsDirectory):
            return .success(documentsDirectory.appendingPathComponent(rootDirectory))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getDirectory(location: FileCacheLocation) -> Result<URL, Error> {
        
        guard let directoryUrl = location.directoryUrl else {
            return .failure(NSError(domain: errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Directory url can't be null."]))
        }
        
        switch getRootDirectory() {
        case .success(let rootDirectory):
            return .success(rootDirectory.appendingPathComponent(directoryUrl.path))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func createDirectoryIfNotExists(location: FileCacheLocation) -> Result<URL, Error> {
        
        switch getDirectory(location: location) {
        
        case .success(let directoryUrl):
            return createDirectoryIfNotExists(directoryUrl: directoryUrl)
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func createDirectoryIfNotExists(directoryUrl: URL) -> Result<URL, Error> {
        
        guard !fileManager.fileExists(atPath: directoryUrl.path) else {
            return .success(directoryUrl)
        }
        
        do {
            try fileManager.createDirectory(
                at: directoryUrl,
                withIntermediateDirectories: true,
                attributes: nil
            )
            return .success(directoryUrl)
        }
        catch let error {
            return .failure(error)
        }
    }
    
    func getFileExists(location: FileCacheLocation) -> Result<Bool, Error> {
        
        switch getFile(location: location) {
        case .success(let url):
            return .success(fileManager.fileExists(atPath: url.path))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getFile(location: FileCacheLocation) -> Result<URL, Error> {
        
        guard let fileUrl = location.fileUrl else {
            return .failure(NSError(domain: errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "File url can't be null."]))
        }
        
        switch getRootDirectory() {
        case .success(let rootDirectory):
            return .success(rootDirectory.appendingPathComponent(fileUrl.path))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getData(location: FileCacheLocation) -> Result<Data?, Error> {
        
        switch getFile(location: location) {
        case .success(let url):
            return .success(fileManager.contents(atPath: url.path))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getUIImage(location: FileCacheLocation) -> Result<UIImage?, Error> {
        
        switch getData(location: location) {
        case .success(let data):
            guard let data = data else {
                return .success(nil)
            }
            return .success(UIImage(data: data))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getImage(location: FileCacheLocation) -> Result<Image?, Error> {
        
        switch getUIImage(location: location) {
        case .success(let uiImage):
            guard let uiImage = uiImage else {
                return .success(nil)
            }
            return .success(Image(uiImage: uiImage))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func storeFile(location: FileCacheLocation, data: Data) -> Result<URL, Error> {
        
        switch createDirectoryIfNotExists(location: location) {
        case .success( _):
            break
        case .failure(let error):
            return .failure(error)
        }
        
        switch getFile(location: location) {
        case .success(let url):
            if fileManager.createFile(atPath: url.path, contents: data, attributes: nil) {
                return .success(url)
            }
            else {
                return .failure(NSError(domain: errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create file at url: \(url.absoluteString)"]))
            }
        case.failure(let error):
            return .failure(error)
        }
    }
    
    func removeRootDirectory() -> Error? {
        
        switch getRootDirectory() {
        case .success(let rootDirectoryUrl):
            return removeItem(url: rootDirectoryUrl)
        case .failure(let error):
            return error
        }
    }
    
    func removeDirectory(location: FileCacheLocation) -> Error? {
        
        switch getDirectory(location: location) {
        case .success(let directoryUrl):
            return removeItem(url: directoryUrl)
        case .failure(let error):
            return error
        }
    }
    
    func removeFile(location: FileCacheLocation) -> Error? {
        
        switch getFile(location: location) {
        case .success(let fileUrl):
            return removeItem(url: fileUrl)
        case .failure(let error):
            return error
        }
    }
    
    func removeItem(url: URL) -> Error? {
        
        do {
            try fileManager.removeItem(at: url)
            return nil
        }
        catch let error {
            return error
        }
    }
    
    func moveContentsOfDirectory(directory: URL, toDirectory: URL) -> Error? {
        
        do {
            let contents: [String] = try fileManager.contentsOfDirectory(atPath: directory.path)
            for item in contents {
                do {
                    try fileManager.moveItem(atPath: directory.appendingPathComponent(item).path, toPath: toDirectory.appendingPathComponent(item).path)
                }
                catch let error {
                    return error
                }
            }
        }
        catch let error {
            return error
        }
        
        return nil
    }
    
    func moveChildDirectoryContentsIntoParent(parentDirectory: URL) -> Error? {
       
        // check if the contents is a single directory and if it is, move contents of this directory up a level into the parent directory
        
        do {
            
            let contentsOfParentDirectory: [String] = try fileManager.contentsOfDirectory(atPath: parentDirectory.path)
            
            guard contentsOfParentDirectory.count == 1 else {
                return nil
            }
            
            let childDirectory: URL = parentDirectory.appendingPathComponent(contentsOfParentDirectory[0])
            
            guard getIsDirectory(url: childDirectory) else {
                return nil
            }
            
            if let moveItemsError = moveContentsOfDirectory(directory: childDirectory, toDirectory: parentDirectory) {
                return moveItemsError
            }
            
            // delete directory since contents were moved
            do {
               try fileManager.removeItem(at: childDirectory)
            }
            catch let error {
                return error
            }
        }
        catch let error {
            
            return error
        }
        
        return nil
    }
}
