//
//  ViewController.swift
//  git-nerd
//
//  Created by Berkus on 25/10/14.
//  Copyright (c) 2014 Atta. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSOpenSavePanelDelegate {
    var commit: GTCommit?
    @IBOutlet weak var date: NSTextField!
    @IBOutlet weak var author: NSTextField!
    @IBOutlet weak var messageDetails: NSTextField!
    @IBOutlet weak var messageTitle: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func repositoryURLForURL(url: NSURL) -> NSURL? {
        // returns the repository URL or nil if it can't be made.
        // If the URL is a file, it should have the extension '.git' - bare repository
        // If the URL is a folder it should have the name '.git'
        // If the URL is a folder, then it should contain a subfolder called '.git
        let kGit = ".git"
        let endPoint = url.lastPathComponent

        NSLog("Checking url %@", url)

        if endPoint.lowercaseString.hasSuffix(kGit) {
            NSLog("Checking url success %@", url)
            return url
        }
        if endPoint == kGit {
            NSLog("Checking url success %@", url)
            return url
        }
        let possibleGitDir = url.URLByAppendingPathComponent(kGit, isDirectory: true)
        if (possibleGitDir.checkResourceIsReachableAndReturnError(nil)) {
            NSLog("Checking url success %@", url)
            return possibleGitDir
        }
        NSLog("Not a valid path");
        return nil
    }

    @IBAction func openNewRepository(sender: AnyObject) {
        var panel = NSOpenPanel()
        panel.delegate = self;
        panel.canChooseDirectories = true;
        panel.showsHiddenFiles = true;

        let window = view.window!

        panel.beginSheetModalForWindow(window) { result in
            if (result == NSFileHandlingPanelCancelButton) {
                NSLog("Canceled")
                return;
            }
            var repo = GTRepository(URL: self.repositoryURLForURL(panel.URL!)!, error:nil)
            NSLog("Found repository %@", repo.fileURL)
            var head = repo.headReferenceWithError(nil)
            NSLog("HEAD commit SHA %@", head.targetSHA)
            self.commit = repo.lookUpObjectBySHA(head.targetSHA, error: nil) as GTCommit!
            NSLog("HEAD commit %@", self.commit!)
            self.messageTitle.stringValue = self.commit!.message
            self.messageDetails.stringValue = self.commit!.messageDetails
            self.author.stringValue = self.commit!.author.name
            self.date.stringValue = self.commit!.commitDate.description
        }
    }

    // MARK - NSOpenPanel delegate

    func panel(sender: AnyObject, shouldEnableURL url: NSURL) -> Bool {
        return true
    }

    func panel(sender: AnyObject, validateURL url: NSURL, error outError: NSErrorPointer) -> Bool {
        if let url = repositoryURLForURL(url) {
            return true
        }
        return false
    }
}
