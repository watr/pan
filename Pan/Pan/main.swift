//
//  main.swift
//  Pan
//
//  Created by HASHIMOTO Wataru on 4/14/16.
//  Copyright © 2016 HASHIMOTO Wataru. All rights reserved.
//
import Foundation
import WebKit

let currentVersionDescription: String = "pan 0.0.2"

let specifiedTitle = NSUserDefaults.standardUserDefaults().stringForKey("title")

var window: NSWindow? = nil

let contentSize =  CGSize(width: 640, height: 800)

class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        if let title = webView.title {
            if specifiedTitle == nil {
                window?.title = title
            }
        }
    }
}
////////////////////////////////////////////////////////////////

let isTty = (isatty(fileno(stdin)) != 0) // stdin come from terminal. if false, maybe come from pipe.

func showHelpAndExit() {
    let helpDescription = "\(currentVersionDescription) (\"$ echo $(html) | pan\")"
    print(helpDescription)
    
    exit(0)
}

if isTty {
    showHelpAndExit()
}

//----------------------------------------------------------------

let appDelegate = AppDelegate()

NSApplication.sharedApplication().setActivationPolicy(.Accessory)
NSApplication.sharedApplication().delegate = appDelegate

var htmlString = ""

while let input = String(data:NSFileHandle.fileHandleWithStandardInput().availableData, encoding: NSUTF8StringEncoding) {
    if input.characters.count == 0 {
        break
    }
    htmlString += input
}

if !(htmlString.isEmpty) {
    let webView = WKWebView(frame: CGRect(origin: CGPointZero, size: contentSize))
    webView.navigationDelegate = appDelegate
    webView.loadHTMLString(htmlString, baseURL: nil)
    
    window = NSWindow(contentRect: CGRect(origin: CGPointZero, size: contentSize), styleMask:(NSTitledWindowMask | NSResizableWindowMask | NSMiniaturizableWindowMask | NSClosableWindowMask), backing:.Buffered, defer:false)
    if let window = window {
        if let title = specifiedTitle {
            window.title = title
        }
        window.contentView = webView
        window.makeKeyAndOrderFront(nil)
        
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
        NSApplication.sharedApplication().run()
    }
}
