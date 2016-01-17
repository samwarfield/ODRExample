//
//  OnDemandResourceProgress.swift
//  ODRExample
//
//  Created by Sam Warfield on 9/28/15.
//  Copyright © 2015 Sam Warfield. All rights reserved.
//

import Foundation

let kOnDemandResourceProgressKeyPath = "fractionCompleted"

class OnDemandResourceProgress
{
    unowned var observer: NSObject
    var progress: NSProgress!
    var onDemandResourceProgressContext = UnsafeMutablePointer<Void>()

    init(progress: NSProgress, observer: NSObject)
    {
        self.progress = progress
        self.observer = observer
        setupObserver()
    }

    func setupObserver()
    {
        progress.addObserver(observer, forKeyPath: kOnDemandResourceProgressKeyPath, options: [.New, .Initial], context: onDemandResourceProgressContext)
    }

    func removeObserver()
    {
        progress.removeObserver(observer, forKeyPath: kOnDemandResourceProgressKeyPath, context: onDemandResourceProgressContext)
    }
}