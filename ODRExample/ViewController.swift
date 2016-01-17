//
//  ViewController.swift
//  ODRExample
//
//  Created by Sam Warfield on 9/28/15.
//  Copyright © 2015 Sam Warfield. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!

    var resourceController: OnDemandResourceController!

    let tags = ["1", "2", "3", "4", "5"]

    override func viewDidLoad()
    {
        super.viewDidLoad()

        resourceController = OnDemandResourceController(processObserver: self)
        
        if let firstTag = tags.first
        {
            let tagsToCheck = [firstTag]
            resourceController.checkIfAvailable(tagsToCheck) { (success, error) -> Void in
                if let error = error
                {
                    switch error.code
                    {
                    case NSBundleOnDemandResourceOutOfSpaceError: // No more space on device
                        print("out of space")
                    case NSBundleOnDemandResourceExceededMaximumSizeError: // No more space in cache, purge something
                        print("exceeded maximum space")
                        self.resourceController.endAllAccess()
//                        self.resourceController.checkIfAvailable(tagsToCheck)
                    default:
                        print(error)
                    }
                }
                self.setImage(firstTag)
            }
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func segmentChanged(sender: UISegmentedControl)
    {
        let tag = tags[sender.selectedSegmentIndex]
        resourceController.checkIfAvailable([tag]) { (success, error) -> Void in
            self.setImage(tag)
        }
    }

    func setImage(tag: String)
    {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.imageView.image = UIImage(named: tag)
        }
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>)
    {
        if let object = object as? NSProgress where keyPath == kOnDemandResourceProgressKeyPath && context == resourceController.processContext(tags[segmentControl.selectedSegmentIndex])
        {
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                self.progressView.progress = Float(object.fractionCompleted)
            }
        }
        else
        {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
}

