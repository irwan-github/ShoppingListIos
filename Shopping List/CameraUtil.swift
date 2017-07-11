//
//  CameraUtil.swift
//  Shopping List
//
//  Created by Mirza Irwan on 10/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//
//  The preferred way to specify the location of a file or directory is to use the NSURL class.
//  Although the NSString class has many methods related to path creation, URLs offer a more robust way to locate files and directories.
//  Path-based URL: file://localhost/Users/steve/Documents/MyFile.txt
//  File reference URL: file:///.file/id=6571367.2773272/
//  String-based path: /Users/steve/Documents/MyFile.txt
//  For standard directories, use the system frameworks to locate the directory first and then use the resulting URL to build a path to the file.

import Foundation
import UIKit

struct CameraUtil {
    
    static var dateFormat = "yyyyMMdd_HHmmss"
    private static var directory: FileManager.SearchPathDirectory = .documentDirectory
    
    //A collision-resistant file name using date-time stamp
    static var filename: String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let timestampFileName = dateFormatter.string(from: Date()) + ".jpeg"
        return timestampFileName
        
    }
    
    //specify locations manually by building a URL or string-based path from known directory names
    static var directoryContainingImageFile: URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: directory, in: .userDomainMask)
        return urls[0]
    }
    
    static var pathToImageFile: URL {
        let url = directoryContainingImageFile.appendingPathComponent(filename)
        return url
    }
    
    func persistImage(data: UIImage) -> URL? {
        
        guard let jpegImage = UIImageJPEGRepresentation(data, 1) else {
            print("Error: JPEG creation")
            return nil
        }
        
        let url = CameraUtil.pathToImageFile
        
        do {
            try jpegImage.write(to: url, options: .atomic)
            print("Success saving photo")
        } catch {
            let nserror = error as NSError
            print("\(#function): Unresolved error \(nserror), \(nserror.userInfo)")
            return nil
        }
        
        return url
        
    }
}
