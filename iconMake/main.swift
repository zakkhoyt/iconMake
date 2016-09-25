//
//  main.swift
//  iconMake
//
//  Created by Zakk Hoyt on 9/21/16.
//  Copyright © 2016 Zakk Hoyt. All rights reserved.
//

import Foundation

let executable = NSProcessInfo.processInfo().arguments[0]

if NSProcessInfo.processInfo().arguments.count < 3 {
    print("\(executable): Two parameters are required.")
    print("1.) <path_to_image> The path to a png file, preferrably 1024x1024 pixels.")
    print("2.) <path_to_output_dir> Path to a dir to output the files. The dir will be created if it doesn't exist. Files inside will be overwritten.")
    print("Example\t\(executable) <path_to_image> <path_to_output_dir>")
    exit(-1)
}


let sourceImagePath = NSProcessInfo.processInfo().arguments[1]
let outputDirPath = NSProcessInfo.processInfo().arguments[2]

let sipsPath = "/usr/bin/sips"




let sourceImageURL = NSURL(fileURLWithPath: sourceImagePath)
let outputDirURL = NSURL(fileURLWithPath: outputDirPath)


func fileNameFromSize(size: String, scale: Double) -> String {
    switch scale {
    case 2:
        return "icon_\(size)@2x.png"
    case 3:
        return "icon_\(size)@3x.png"
    default:
        return "icon_\(size).png"
    }
}

func createImages() {
    
    let scales = [8, 16, 20, 29, 32, 40, 44, 50, 60, 70, 72, 76, 83.5, 96, 122, 128, 148, 174, 200, 256, 320, 512, 1024]
    
    // Create output dir
    do {
        try NSFileManager.defaultManager().createDirectoryAtURL(outputDirURL, withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
        print("Error creating output dir: " + outputDirURL.absoluteString + " " + error.localizedDescription)
        exit(-1)
    }
    
    for scale in scales {
        
        let size = String(scale)
        do {
            let outputURL = outputDirURL.URLByAppendingPathComponent("icon_\(size).png")
            do {
                try NSFileManager.defaultManager().removeItemAtURL(outputURL)
            } catch let _ as NSError {
                //            print("Warning: Cannot remove output dir: " + outputURL.absoluteString)
            }
            let task = NSTask()
            task.launchPath = sipsPath
            task.arguments = [sourceImagePath, "-z", String(scale), String(scale), "--out", outputURL.path!]
            task.launch()
            print("Resizing icon to " + outputURL.lastPathComponent!)
        }
        
        do {
            let outputURL = outputDirURL.URLByAppendingPathComponent("icon_\(size)@2x.png")
            do {
                try NSFileManager.defaultManager().removeItemAtURL(outputURL)
            } catch let _ as NSError {
                //            print("Warning: Cannot remove output dir: " + outputURL.absoluteString)
            }
            let task = NSTask()
            task.launchPath = sipsPath
            task.arguments = [sourceImagePath, "-z", String(2*scale), String(2*scale), "--out", outputURL.path!]
            task.launch()
            print("Resizing icon to " + outputURL.lastPathComponent!)
        }
        
        do {
            let outputURL = outputDirURL.URLByAppendingPathComponent("icon_\(size)@3x.png")
            do {
                try NSFileManager.defaultManager().removeItemAtURL(outputURL)
            } catch let _ as NSError {
                //            print("Warning: Cannot remove output dir: " + outputURL.absoluteString)
            }
            
            let task = NSTask()
            task.launchPath = sipsPath
            task.arguments = [sourceImagePath, "-z", String(3*scale), String(3*scale), "--out", outputURL.path!]
            task.launch()
            print("Resizing icon to " + outputURL.lastPathComponent!)
        }
    }
}

func createAppIcon() {
    
    let tuples = [
        (29.0, [2, 3], "iphone"),
        (40.0, [2, 3], "iphone"),
        (60.0, [2, 3], "iphone"),
        (29.0, [1, 2], "ipad"),
        (40.0, [1, 2], "ipad"),
        (76.0, [1, 2], "ipad"),
        (83.5, [2], "ipad"),
        ]
    
    
    // Create AppIcon dir
    let appIconURL = outputDirURL.URLByAppendingPathComponent("AppIcon.appiconset")
    let jsonURL = appIconURL.URLByAppendingPathComponent("Contents.json")
    do {
        try NSFileManager.defaultManager().createDirectoryAtURL(appIconURL, withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
        print("Error creating AppIcon dir: " + error.localizedDescription)
        exit(-1)
    }
    
    // Setup JSON
    var json = [String: AnyObject]()
    
    let info = [
        "version": 1,
        "author": "xcode"
    ]
    
    json["info"] = info
    
    var images = [[String: AnyObject]]()
    
    for tuple in tuples {
        let size = tuple.0
        let scales = tuple.1
        let idiom = tuple.2

        for scale in scales {
            var image = [String: AnyObject]()
            image["size"] = "\(Int(size))x\(Int(size))"
            image["idiom"] = idiom
            image["filename"] = fileNameFromSize(String(size), scale: Double(scale))
            image["scale"] = "\(Int(scale))x"
            images.append(image)
        }
    }
    
    json["images"] = images
    
    // Write json
    do {
        let data = try NSJSONSerialization.dataWithJSONObject(json, options: [])
        try data.writeToURL(jsonURL, options: .AtomicWrite)
    } catch let error as NSError {
        print("Error writing json to Contents.json: " + error.localizedDescription)
        exit(-1)
    }
    
    
    
    // Copy files into AppIcon
    for tuple in tuples {
        let size = tuple.0
        let scales = tuple.1
        
        for scale in scales {
            //let fileName = "icon_\(name)@2x.png"
            let fileName = fileNameFromSize(String(size), scale: Double(scale))
            let source = outputDirURL.URLByAppendingPathComponent(fileName)
            let dest = appIconURL.URLByAppendingPathComponent(fileName)
            
            do {
                try NSFileManager.defaultManager().copyItemAtURL(source, toURL: dest)
            } catch let error as NSError {
                print("Error copying image file to Contents.json: " + error.localizedDescription)
            }
        }
    }
    
    
    
}


createImages()
createAppIcon()


exit(0)
