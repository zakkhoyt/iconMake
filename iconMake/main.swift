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


let scales = [8, 16, 20, 29, 32, 40, 44, 50, 60, 70, 72, 76, 83.5, 96, 122, 128, 148, 174, 200, 256, 320, 512, 1024]

let sourcdImageURL = NSURL(fileURLWithPath: sourceImagePath)
let outputDirURL = NSURL(fileURLWithPath: outputDirPath)



// Create output dir
do {
    try NSFileManager.defaultManager().createDirectoryAtURL(outputDirURL, withIntermediateDirectories: true, attributes: nil)
} catch let error as NSError {
    print("Error creating output dir: " + outputDirURL.absoluteString)
    exit(-1)
}

for scale in scales {
    
    let suffix = String(scale)
    do {
        let outputURL = outputDirURL.URLByAppendingPathComponent("icon_\(suffix).png")
        do {
            try NSFileManager.defaultManager().removeItemAtURL(outputURL)
        } catch let error as NSError {
            //            print("Warning: Cannot remove output dir: " + outputURL.absoluteString)
        }
        let task = NSTask()
        task.launchPath = sipsPath
        task.arguments = [sourceImagePath, "-z", String(scale), String(scale), "--out", outputURL.path!]
        task.launch()
        print("Resizing icon to " + outputURL.lastPathComponent!)
    }
    
    do {
        let outputURL = outputDirURL.URLByAppendingPathComponent("icon_\(suffix)@2x.png")
        do {
            try NSFileManager.defaultManager().removeItemAtURL(outputURL)
        } catch let error as NSError {
            //            print("Warning: Cannot remove output dir: " + outputURL.absoluteString)
        }
        let task = NSTask()
        task.launchPath = sipsPath
        task.arguments = [sourceImagePath, "-z", String(2*scale), String(2*scale), "--out", outputURL.path!]
        task.launch()
        print("Resizing icon to " + outputURL.lastPathComponent!)
    }
    
    do {
        let outputURL = outputDirURL.URLByAppendingPathComponent("icon_\(suffix)@3x.png")
        do {
            try NSFileManager.defaultManager().removeItemAtURL(outputURL)
        } catch let error as NSError {
            //            print("Warning: Cannot remove output dir: " + outputURL.absoluteString)
        }
        
        let task = NSTask()
        task.launchPath = sipsPath
        task.arguments = [sourceImagePath, "-z", String(3*scale), String(3*scale), "--out", outputURL.path!]
        task.launch()
        print("Resizing icon to " + outputURL.lastPathComponent!)
    }
}

exit(0)
