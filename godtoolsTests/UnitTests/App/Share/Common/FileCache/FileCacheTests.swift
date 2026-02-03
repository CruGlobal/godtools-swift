//
//  FileCacheTests.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import UIKit

@Suite(.serialized)
class FileCacheTests {
    
    private let testsFileCacheRootDirectory: String = "tests_file_cache"
    private let tempDirectoryName: String = "temp_directory"
    
    @Test("")
    func returnsRootDirectoryUrl() async throws {
        
        let fileCache = try getTestsFileCache()
        
        let url = try fileCache.getRootDirectory()
        
        #expect(url.absoluteString.contains(testsFileCacheRootDirectory))
    }
    
    @Test("")
    func returnsDirectoryUrl() async throws {
        
        let fileCache = try getTestsFileCache()
        
        let location = FileCacheLocation(relativeUrlString: testsFileCacheRootDirectory)
        
        let url = try fileCache.getDirectory(location: location)
        
        #expect(url.absoluteString.contains(testsFileCacheRootDirectory))
    }
    
    @Test("")
    func isDirectory() async throws {
        
        let fileCache = try getTestsFileCache()

        let rootDirectoryUrl: URL = try fileCache.getRootDirectory()

        let newDiretoryUrl: URL = rootDirectoryUrl.appendingPathComponent(tempDirectoryName)
        
        _ = try fileCache.createDirectoryIfNotExists(directoryUrl: newDiretoryUrl)
        
        let isDirectory: Bool = fileCache.getIsDirectory(url: newDiretoryUrl)
        
        #expect(isDirectory == true)
    }
    
    @Test("")
    func isNotDirectory() async throws {
        
        let fileCache = try getTestsFileCache()
        
        let rootDirectoryUrl: URL = try fileCache.getRootDirectory()
        
        let newDiretoryUrl: URL = rootDirectoryUrl.appendingPathComponent(tempDirectoryName)
        
        let isDirectory: Bool = fileCache.getIsDirectory(url: newDiretoryUrl)
        
        #expect(isDirectory == false)
    }
    
    @Test("")
    func isFile() async throws {
        
        let fileCache = try getTestsFileCache()
              
        let optionalFileData: Data? = "text data".data(using: .utf8)
        let fileData: Data = try #require(optionalFileData)
        let fileName: String = "file.txt"
        let fileLocation = FileCacheLocation(relativeUrlString: "\(tempDirectoryName)/\(fileName)")
        
        _ = try fileCache.storeFile(location: fileLocation, data: fileData)
        
        let fileExists: Bool = try fileCache.getFileExists(location: fileLocation)
        
        #expect(fileExists == true)
        
        let fileUrl: URL = try fileCache.getFile(location: fileLocation)
        
        #expect(fileUrl.absoluteString.contains(fileName))
    }
    
    @Test("")
    func removeDirectory() async throws {
        
        let fileCache = try getTestsFileCache()
        
        let rootDirectoryUrl: URL = try fileCache.getRootDirectory()
        
        let newDiretoryUrl: URL = rootDirectoryUrl.appendingPathComponent(tempDirectoryName)
        
        _ = try fileCache.createDirectoryIfNotExists(directoryUrl: newDiretoryUrl)
             
        #expect(fileCache.getIsDirectory(url: newDiretoryUrl) == true)
        
        try fileCache.removeItem(url: newDiretoryUrl)
               
        #expect(fileCache.getIsDirectory(url: newDiretoryUrl) == false)
    }
    
    @Test("")
    func removeFile() async throws {
        
        let fileCache = try getTestsFileCache()
                 
        let optionalFileData: Data? = "text data".data(using: .utf8)
        let fileData: Data = try #require(optionalFileData)
        let fileName: String = "file.txt"
        let fileLocation = FileCacheLocation(relativeUrlString: "\(tempDirectoryName)/\(fileName)")
        
        _ = try fileCache.storeFile(location: fileLocation, data: fileData)
                
        #expect(try fileCache.getFileExists(location: fileLocation) == true)
        
        try fileCache.removeFile(location: fileLocation)
                
        #expect(try fileCache.getFileExists(location: fileLocation) == false)
    }
    
    @Test("")
    func getData() async throws {
        
        let fileCache = try getTestsFileCache()
               
        let optionalFileData: Data? = "text data".data(using: .utf8)
        let fileData: Data = try #require(optionalFileData)
        let fileName: String = "file.txt"
        let fileLocation = FileCacheLocation(relativeUrlString: "\(tempDirectoryName)/\(fileName)")
        
        _ = try fileCache.storeFile(location: fileLocation, data: fileData)
        
        #expect(try fileCache.getData(location: fileLocation) != nil)
    }
    
    @Test("")
    func moveContentsOfDirectoryToDirectory() async throws {
        
        let fileCache = try getTestsFileCache()
        
        let rootDirectoryUrl: URL = try fileCache.getRootDirectory()
        
        // add directory original and move to
        
        let originalFilesDirectoryName: String = "original_files"
        let originalFilesDirectory: URL = rootDirectoryUrl.appendingPathComponent(originalFilesDirectoryName)
        
        _ = try fileCache.createDirectoryIfNotExists(directoryUrl: originalFilesDirectory)
        
        let moveFilesToDirectoryName: String = "move_files_to"
        let moveFilesToDirectory: URL = rootDirectoryUrl.appendingPathComponent(moveFilesToDirectoryName)
        
        _ = try fileCache.createDirectoryIfNotExists(directoryUrl: moveFilesToDirectory)
        
        try #require(fileCache.getIsDirectory(url: originalFilesDirectory))
        try #require(fileCache.getIsDirectory(url: moveFilesToDirectory))
        
        let files: [String] = ["file_0", "file_1", "file_2", "file_3"]
        let fileExtension: String = ".txt"
        
        // add files to original directory
        
        for file in files {
            
            let fileData: Data = try #require("text data".data(using: .utf8))
            let fileRelativePath: String = originalFilesDirectoryName + "/" + file + fileExtension
            let fileLocation = FileCacheLocation(relativeUrlString: fileRelativePath)
            
            _ = try fileCache.storeFile(location: fileLocation, data: fileData)
        }
        
        // check files exist in original directory and not move to directory
        
        for file in files {
            
            #expect(try fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: originalFilesDirectoryName + "/" + file + fileExtension)) == true)
            
            #expect(try fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: moveFilesToDirectoryName + "/" + file + fileExtension)) == false)
        }
        
        try fileCache.moveContentsOfDirectory(directory: originalFilesDirectory, toDirectory: moveFilesToDirectory)
        
        // after move, check files do not exist in original directory and exist in move to directory
        
        for file in files {
            
            #expect(try fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: originalFilesDirectoryName + "/" + file + fileExtension)) == false)
            
            #expect(try fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: moveFilesToDirectoryName + "/" + file + fileExtension)) == true)
        }
    }
    
    @Test("")
    func moveContentsOfChildDirectoryToParentDirectory() async throws {
        
        let fileCache = try getTestsFileCache()
        
        let rootDirectoryUrl: URL = try fileCache.getRootDirectory()
        
        // add parent directory
        
        let parentDirectoryName: String = "parent_directory"
        let parentDirectoryUrl: URL = rootDirectoryUrl.appendingPathComponent(parentDirectoryName)
        
        _ = try fileCache.createDirectoryIfNotExists(directoryUrl: parentDirectoryUrl)
        
        // add child directory to parent directory
        
        let childDirectoryName: String = "child_directory"
        let childDirectoryUrl: URL = parentDirectoryUrl.appendingPathComponent(childDirectoryName)
        
        _ = try fileCache.createDirectoryIfNotExists(directoryUrl: childDirectoryUrl)
        
        // ensure directories are added
        
        try #require(fileCache.getIsDirectory(url: parentDirectoryUrl))
        try #require(fileCache.getIsDirectory(url: childDirectoryUrl))
        
        let files: [String] = ["file_0", "file_1", "file_2", "file_3"]
        let fileExtension: String = ".txt"
        
        // add files to child directory
        
        for file in files {
            
            let fileData: Data = try #require("text data".data(using: .utf8))
            let fileRelativePath: String = parentDirectoryName + "/" + childDirectoryName + "/" + file + fileExtension
            let fileLocation = FileCacheLocation(relativeUrlString: fileRelativePath)
            
            _ = try fileCache.storeFile(location: fileLocation, data: fileData)
        }
        
        // check files exist in child directory and not parent directory
        
        for file in files {
            
            #expect(try fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: parentDirectoryName + "/" + childDirectoryName + "/" + file + fileExtension)) == true)
            
            #expect(try fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: parentDirectoryName + "/" + file + fileExtension)) == false)
        }
        
        try fileCache.moveChildDirectoryContentsIntoParent(parentDirectory: parentDirectoryUrl)
        
        // after move ensure child directory no longer exists in parent directory
        
        try #require(fileCache.getIsDirectory(url: childDirectoryUrl) == false)
        
        // after move, check files exist in parent directory
        
        for file in files {
            
            #expect(try fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: childDirectoryName + "/" + file + fileExtension)) == false)
            
            #expect(try fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: parentDirectoryName + "/" + file + fileExtension)) == true)
        }
    }
    
    @Test("")
    func moveContentsOfChildDirectoryToParentDirectoryFailsWhenMoreContentsThanSingleDirectory() async throws {
        
        let fileCache = try getTestsFileCache()
        
        let rootDirectoryUrl: URL = try fileCache.getRootDirectory()
        
        // add parent directory
        
        let parentDirectoryName: String = "parent_directory"
        let parentDirectoryUrl: URL = rootDirectoryUrl.appendingPathComponent(parentDirectoryName)
        
        _ = try fileCache.createDirectoryIfNotExists(directoryUrl: parentDirectoryUrl)
        
        // add child directory to parent directory
        
        let childDirectoryName: String = "child_directory"
        let childDirectoryUrl: URL = parentDirectoryUrl.appendingPathComponent(childDirectoryName)
        
        _ = try fileCache.createDirectoryIfNotExists(directoryUrl: childDirectoryUrl)
        
        // add additional directory to parent directory
        
        let additionalDirectoryName: String = "additional_directory"
        let additionalDirectoryUrl: URL = parentDirectoryUrl.appendingPathComponent(additionalDirectoryName)
        
        _ = try fileCache.createDirectoryIfNotExists(directoryUrl: additionalDirectoryUrl)
        
        // ensure directories are added
        
        try #require(fileCache.getIsDirectory(url: parentDirectoryUrl))
        try #require(fileCache.getIsDirectory(url: childDirectoryUrl))
        try #require(fileCache.getIsDirectory(url: additionalDirectoryUrl))
        
        let files: [String] = ["file_0", "file_1", "file_2", "file_3"]
        let fileExtension: String = ".txt"
        
        // add files to child directory
        
        for file in files {
            
            let fileData: Data = try #require("text data".data(using: .utf8))
            let fileRelativePath: String = parentDirectoryName + "/" + childDirectoryName + "/" + file + fileExtension
            let fileLocation = FileCacheLocation(relativeUrlString: fileRelativePath)
            
            _ = try fileCache.storeFile(location: fileLocation, data: fileData)
        }
        
        // check files exist in child directory and not parent directory
        
        for file in files {
            
            #expect(try fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: parentDirectoryName + "/" + childDirectoryName + "/" + file + fileExtension)) == true)
            
            #expect(try fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: parentDirectoryName + "/" + file + fileExtension)) == false)
        }
        
        try fileCache.moveChildDirectoryContentsIntoParent(parentDirectory: parentDirectoryUrl)
        
        // ensure child directory still exists since move should fail
        
        try #require(fileCache.getIsDirectory(url: childDirectoryUrl) == true)
        
        // check files exist in child directory and not parent directory
        
        for file in files {
            
            #expect(try fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: parentDirectoryName + "/" + childDirectoryName + "/" + file + fileExtension)) == true)
            
            #expect(try fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: parentDirectoryName + "/" + file + fileExtension)) == false)
        }
    }
    
    @Test("")
    func getUIImage() async throws {
        
        let fileCache = try getTestsFileCache()
        
        let imageFromPreviewAssets: UIImage = try #require(UIImage(named: "previewBannerImage", in: Bundle.main, with: nil))
        let imageData: Data = try #require(imageFromPreviewAssets.jpegData(compressionQuality: 0.8))
        
        let imageName: String = "previewAsset.jpg"
        
        let fileLocation = FileCacheLocation(relativeUrlString: imageName)
        
        _ = try fileCache.storeFile(location: fileLocation, data: imageData)
        
        #expect(try fileCache.getUIImage(location: fileLocation) != nil)
    }
    
    @Test("")
    func getImage() async throws {
        
        let fileCache = try getTestsFileCache()
        
        let imageFromPreviewAssets: UIImage = try #require(UIImage(named: "previewBannerImage", in: Bundle.main, with: nil))
        let imageData: Data = try #require(imageFromPreviewAssets.jpegData(compressionQuality: 0.8))
        
        let imageName: String = "previewAsset.jpg"
        
        let fileLocation = FileCacheLocation(relativeUrlString: imageName)
        
        _ = try fileCache.storeFile(location: fileLocation, data: imageData)
        
        #expect(try fileCache.getImage(location: fileLocation) != nil)
    }
}

extension FileCacheTests {
    
    private func getTestsFileCache() throws -> FileCache {
        
        do {
            try FileCache(rootDirectory: testsFileCacheRootDirectory)
                .removeRootDirectory()
        }
        catch _ {
            
        }
        
        return FileCache(
            rootDirectory: testsFileCacheRootDirectory
        )
    }
}
