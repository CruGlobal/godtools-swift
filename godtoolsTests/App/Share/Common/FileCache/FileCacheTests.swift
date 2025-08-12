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

@Suite(.serialized)
struct FileCacheTests {
    
    private static let testsFileCacheRootDirectory: String = "tests_file_cache"
    private static let tempDirectoryName: String = "temp_directory"
    
    @Test("")
    func returnsRootDirectoryUrl() async throws {
        
        let fileCache = Self.getTestsFileCache()
        
        switch fileCache.getRootDirectory() {
        case .success(let url):
            #expect(url.absoluteString.contains(Self.testsFileCacheRootDirectory))
        case .failure(let error):
            throw error
        }
    }
    
    @Test("")
    func returnsDirectoryUrl() async throws {
        
        let fileCache = Self.getTestsFileCache()
        let location = FileCacheLocation(relativeUrlString: Self.testsFileCacheRootDirectory)
        
        switch fileCache.getDirectory(location: location) {
        case .success(let url):
            #expect(url.absoluteString.contains(Self.testsFileCacheRootDirectory))
        case .failure(let error):
            throw error
        }
    }
    
    @Test("")
    func isDirectory() async throws {
        
        let fileCache = Self.getTestsFileCache()
        let rootDirectoryUrl: URL
        
        switch fileCache.getRootDirectory() {
        case .success(let url):
            rootDirectoryUrl = url
        case .failure(let error):
            throw error
        }
        
        let newDiretoryUrl: URL = rootDirectoryUrl.appendingPathComponent(Self.tempDirectoryName)
        
        switch fileCache.createDirectoryIfNotExists(directoryUrl: newDiretoryUrl) {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
        
        let isDirectory: Bool = fileCache.getIsDirectory(url: newDiretoryUrl)
        
        #expect(isDirectory == true)
    }
    
    @Test("")
    func isNotDirectory() async throws {
        
        let fileCache = Self.getTestsFileCache()
        let rootDirectoryUrl: URL
        
        switch fileCache.getRootDirectory() {
        case .success(let url):
            rootDirectoryUrl = url
        case .failure(let error):
            throw error
        }
        
        let newDiretoryUrl: URL = rootDirectoryUrl.appendingPathComponent(Self.tempDirectoryName)
        
        let isDirectory: Bool = fileCache.getIsDirectory(url: newDiretoryUrl)
        
        #expect(isDirectory == false)
    }
    
    @Test("")
    func isFile() async throws {
        
        let fileCache = Self.getTestsFileCache()
        
        switch fileCache.getRootDirectory() {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
                
        let optionalFileData: Data? = "text data".data(using: .utf8)
        let fileData: Data = try #require(optionalFileData)
        let fileName: String = "file.txt"
        let fileLocation = FileCacheLocation(relativeUrlString: "\(Self.tempDirectoryName)/\(fileName)")
        
        switch fileCache.storeFile(location: fileLocation, data: fileData) {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
        
        switch fileCache.getFileExists(location: fileLocation) {
        case .success(let fileExists):
            #expect(fileExists == true)
        case .failure(let error):
            throw error
        }
        
        let fileUrl: URL
        
        switch fileCache.getFile(location: fileLocation) {
        case .success(let url):
            fileUrl = url
        case .failure(let error):
            throw error
        }
        
        #expect(fileUrl.absoluteString.contains(fileName))
    }
    
    @Test("")
    func removeDirectory() async throws {
        
        let fileCache = Self.getTestsFileCache()
        let rootDirectoryUrl: URL
        
        switch fileCache.getRootDirectory() {
        case .success(let url):
            rootDirectoryUrl = url
        case .failure(let error):
            throw error
        }
        
        let newDiretoryUrl: URL = rootDirectoryUrl.appendingPathComponent(Self.tempDirectoryName)
        
        switch fileCache.createDirectoryIfNotExists(directoryUrl: newDiretoryUrl) {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
                
        #expect(fileCache.getIsDirectory(url: newDiretoryUrl) == true)
        
        if let error = fileCache.removeItem(url: newDiretoryUrl) {
            throw error
        }
                
        #expect(fileCache.getIsDirectory(url: newDiretoryUrl) == false)
    }
    
    @Test("")
    func removeFile() async throws {
        
        let fileCache = Self.getTestsFileCache()
        
        switch fileCache.getRootDirectory() {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
                
        let optionalFileData: Data? = "text data".data(using: .utf8)
        let fileData: Data = try #require(optionalFileData)
        let fileName: String = "file.txt"
        let fileLocation = FileCacheLocation(relativeUrlString: "\(Self.tempDirectoryName)/\(fileName)")
        
        switch fileCache.storeFile(location: fileLocation, data: fileData) {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
        
        switch fileCache.getFileExists(location: fileLocation) {
        case .success(let fileExists):
            #expect(fileExists == true)
        case .failure(let error):
            throw error
        }
        
        if let error = fileCache.removeFile(location: fileLocation) {
            throw error
        }
        
        switch fileCache.getFileExists(location: fileLocation) {
        case .success(let fileExists):
            #expect(fileExists == false)
        case .failure(let error):
            throw error
        }
    }
    
    @Test("")
    func getData() async throws {
        
        let fileCache = Self.getTestsFileCache()
        
        switch fileCache.getRootDirectory() {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
                
        let optionalFileData: Data? = "text data".data(using: .utf8)
        let fileData: Data = try #require(optionalFileData)
        let fileName: String = "file.txt"
        let fileLocation = FileCacheLocation(relativeUrlString: "\(Self.tempDirectoryName)/\(fileName)")
        
        switch fileCache.storeFile(location: fileLocation, data: fileData) {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
        
        switch fileCache.getData(location: fileLocation) {
        case .success(let data):
            #expect(data != nil)
        case .failure(let error):
            throw error
        }
    }
    
    @Test("")
    func moveContentsOfDirectoryToDirectory() async throws {
        
        let fileCache = Self.getTestsFileCache()
        let rootDirectoryUrl: URL
        
        switch fileCache.getRootDirectory() {
        case .success(let url):
            rootDirectoryUrl = url
        case .failure(let error):
            throw error
        }
        
        // add directory original and move to
        
        let originalFilesDirectoryName: String = "original_files"
        let originalFilesDirectory: URL = rootDirectoryUrl.appendingPathComponent(originalFilesDirectoryName)
        
        switch fileCache.createDirectoryIfNotExists(directoryUrl: originalFilesDirectory) {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
        
        let moveFilesToDirectoryName: String = "move_files_to"
        let moveFilesToDirectory: URL = rootDirectoryUrl.appendingPathComponent(moveFilesToDirectoryName)
        
        switch fileCache.createDirectoryIfNotExists(directoryUrl: moveFilesToDirectory) {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
        
        try #require(fileCache.getIsDirectory(url: originalFilesDirectory))
        try #require(fileCache.getIsDirectory(url: moveFilesToDirectory))
        
        let files: [String] = ["file_0", "file_1", "file_2", "file_3"]
        let fileExtension: String = ".txt"
        
        // add files to original directory
        
        for file in files {
            
            let fileData: Data = try #require("text data".data(using: .utf8))
            let fileRelativePath: String = originalFilesDirectoryName + "/" + file + fileExtension
            let fileLocation = FileCacheLocation(relativeUrlString: fileRelativePath)
            
            switch fileCache.storeFile(location: fileLocation, data: fileData) {
            case .success( _):
                break
            case .failure(let error):
                throw error
            }
        }
        
        // check files exist in original directory and not move to directory
        
        for file in files {
            
            switch fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: originalFilesDirectoryName + "/" + file + fileExtension)) {
            case .success(let fileExists):
                #expect(fileExists == true)
            case .failure(let error):
                throw error
            }
            
            switch fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: moveFilesToDirectoryName + "/" + file + fileExtension)) {
            case .success(let fileExists):
                #expect(fileExists == false)
            case .failure(let error):
                throw error
            }
        }
        
        if let error = fileCache.moveContentsOfDirectory(directory: originalFilesDirectory, toDirectory: moveFilesToDirectory) {
            throw error
        }
        
        // after move, check files do not exist in original directory and exist in move to directory
        
        for file in files {
            
            switch fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: originalFilesDirectoryName + "/" + file + fileExtension)) {
            case .success(let fileExists):
                #expect(fileExists == false)
            case .failure(let error):
                throw error
            }
            
            switch fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: moveFilesToDirectoryName + "/" + file + fileExtension)) {
            case .success(let fileExists):
                #expect(fileExists == true)
            case .failure(let error):
                throw error
            }
        }
    }
    
    @Test("")
    func moveContentsOfChildDirectoryToParentDirectory() async throws {
        
        let fileCache = Self.getTestsFileCache()
        let rootDirectoryUrl: URL
        
        switch fileCache.getRootDirectory() {
        case .success(let url):
            rootDirectoryUrl = url
        case .failure(let error):
            throw error
        }
        
        // add parent directory
        
        let parentDirectoryName: String = "parent_directory"
        let parentDirectoryUrl: URL = rootDirectoryUrl.appendingPathComponent(parentDirectoryName)
        
        switch fileCache.createDirectoryIfNotExists(directoryUrl: parentDirectoryUrl) {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
        
        // add child directory to parent directory
        
        let childDirectoryName: String = "child_directory"
        let childDirectoryUrl: URL = parentDirectoryUrl.appendingPathComponent(childDirectoryName)
        
        switch fileCache.createDirectoryIfNotExists(directoryUrl: childDirectoryUrl) {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
        
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
            
            switch fileCache.storeFile(location: fileLocation, data: fileData) {
            case .success( _):
                break
            case .failure(let error):
                throw error
            }
        }
        
        // check files exist in child directory and not parent directory
        
        for file in files {
            
            switch fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: parentDirectoryName + "/" + childDirectoryName + "/" + file + fileExtension)) {
            case .success(let fileExists):
                #expect(fileExists == true)
            case .failure(let error):
                throw error
            }
            
            switch fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: parentDirectoryName + "/" + file + fileExtension)) {
            case .success(let fileExists):
                #expect(fileExists == false)
            case .failure(let error):
                throw error
            }
        }
        
        if let error = fileCache.moveChildDirectoryContentsIntoParent(parentDirectory: parentDirectoryUrl) {
            throw error
        }
        
        // after move ensure child directory no longer exists in parent directory
        
        try #require(fileCache.getIsDirectory(url: childDirectoryUrl) == false)
        
        // after move, check files exist in parent directory
        
        for file in files {
            
            switch fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: childDirectoryName + "/" + file + fileExtension)) {
            case .success(let fileExists):
                #expect(fileExists == false)
            case .failure(let error):
                throw error
            }
            
            switch fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: parentDirectoryName + "/" + file + fileExtension)) {
            case .success(let fileExists):
                #expect(fileExists == true)
            case .failure(let error):
                throw error
            }
        }
    }
    
    @Test("")
    func moveContentsOfChildDirectoryToParentDirectoryFailsWhenMoreContentsThanSingleDirectory() async throws {
        
        let fileCache = Self.getTestsFileCache()
        let rootDirectoryUrl: URL
        
        switch fileCache.getRootDirectory() {
        case .success(let url):
            rootDirectoryUrl = url
        case .failure(let error):
            throw error
        }
        
        // add parent directory
        
        let parentDirectoryName: String = "parent_directory"
        let parentDirectoryUrl: URL = rootDirectoryUrl.appendingPathComponent(parentDirectoryName)
        
        switch fileCache.createDirectoryIfNotExists(directoryUrl: parentDirectoryUrl) {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
        
        // add child directory to parent directory
        
        let childDirectoryName: String = "child_directory"
        let childDirectoryUrl: URL = parentDirectoryUrl.appendingPathComponent(childDirectoryName)
        
        switch fileCache.createDirectoryIfNotExists(directoryUrl: childDirectoryUrl) {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
        
        // add additional directory to parent directory
        
        let additionalDirectoryName: String = "additional_directory"
        let additionalDirectoryUrl: URL = parentDirectoryUrl.appendingPathComponent(additionalDirectoryName)
        
        switch fileCache.createDirectoryIfNotExists(directoryUrl: additionalDirectoryUrl) {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
        
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
            
            switch fileCache.storeFile(location: fileLocation, data: fileData) {
            case .success( _):
                break
            case .failure(let error):
                throw error
            }
        }
        
        // check files exist in child directory and not parent directory
        
        for file in files {
            
            switch fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: parentDirectoryName + "/" + childDirectoryName + "/" + file + fileExtension)) {
            case .success(let fileExists):
                #expect(fileExists == true)
            case .failure(let error):
                throw error
            }
            
            switch fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: parentDirectoryName + "/" + file + fileExtension)) {
            case .success(let fileExists):
                #expect(fileExists == false)
            case .failure(let error):
                throw error
            }
        }
        
        if let error = fileCache.moveChildDirectoryContentsIntoParent(parentDirectory: parentDirectoryUrl) {
            throw error
        }
        
        // ensure child directory still exists since move should fail
        
        try #require(fileCache.getIsDirectory(url: childDirectoryUrl) == true)
        
        // check files exist in child directory and not parent directory
        
        for file in files {
            
            switch fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: parentDirectoryName + "/" + childDirectoryName + "/" + file + fileExtension)) {
            case .success(let fileExists):
                #expect(fileExists == true)
            case .failure(let error):
                throw error
            }
            
            switch fileCache.getFileExists(location: FileCacheLocation(relativeUrlString: parentDirectoryName + "/" + file + fileExtension)) {
            case .success(let fileExists):
                #expect(fileExists == false)
            case .failure(let error):
                throw error
            }
        }
    }
}

extension FileCacheTests {
    
    private static func getTestsFileCache() -> FileCache {
        Self.clearTestsFileCache()
        return FileCache(rootDirectory: Self.testsFileCacheRootDirectory)
    }
    
    private static func clearTestsFileCache() {
        _ = FileCache(rootDirectory: Self.testsFileCacheRootDirectory).removeRootDirectory()
    }
}
