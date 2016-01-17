//
//  OnDemandResourceController.swift
//  ODRExample
//
//  Created by Sam Warfield on 9/28/15.
//  Copyright © 2015 Sam Warfield. All rights reserved.
//

import Foundation

class OnDemandResourceController
{
    typealias OnDemandResourceCompletionHandler = (Bool, NSError?) -> Void

    unowned let processObserver: NSObject

    let minimumNumberOfResourcesToKeep = 1 // If storage gets tight we need the current resource

    var resourceRequests = [String: NSBundleResourceRequest]()
    var resourceProgress = [String: OnDemandResourceProgress]()

    init(processObserver: NSObject)
    {
        self.processObserver = processObserver
    }

    func checkIfAvailable(tags: [String], completionHandler: OnDemandResourceCompletionHandler)
    {
        let tagsSet = Set(tags)
        tagsSet.forEach { tag in
            let individualTagSet = Set([tag])
            let resourceRequest = NSBundleResourceRequest(tags: individualTagSet)
            addRequestToInUseCache(resourceRequest)
            resourceRequest.conditionallyBeginAccessingResourcesWithCompletionHandler { available -> Void in
                if available
                {
                    completionHandler(available, nil)
                }
                else
                {
                    self.accessResource(tag) { (success, error) -> Void in
                        completionHandler(success, error)
                    }
                }
            }
        }
    }

    func accessResource(tag: String, completionHandler: OnDemandResourceCompletionHandler)
    {
        if let resourceRequest = resourceRequests[tag]
        {
            resourceProgress[tag] = OnDemandResourceProgress(progress: resourceRequest.progress, observer: processObserver)
            resourceRequest.beginAccessingResourcesWithCompletionHandler { error -> Void in
                if let progress = self.resourceProgress[tag]
                {
                    progress.removeObserver()
                }
                if let error = error
                {
                    print("Error: \(error)")
                    switch error.code
                    {
                    case NSBundleOnDemandResourceInvalidTagError:
                        print("typo in the tag list")
                    case NSBundleOnDemandResourceOutOfSpaceError:
                        print("out of space")
                    case NSBundleOnDemandResourceExceededMaximumSizeError:
                        print("exceeded maximum space")
                    default:
                        print(error)
                    }
                }
                completionHandler(error == nil, error)
            }
        }
    }

    func addRequestToInUseCache(request: NSBundleResourceRequest)
    {
        if let tag = request.tags.first
        {
            resourceRequests[tag] = request
        }
    }

    func hasResourcesToEnd() -> Bool
    {
        return resourceRequests.count > minimumNumberOfResourcesToKeep
    }

    func endAccess(tag: String)
    {
        resourceRequests.removeValueForKey(tag)
    }

    func endAllAccess()
    {
        resourceRequests.removeAll()
    }

    func processContext(tag: String) -> UnsafeMutablePointer<Void>
    {
        var context = UnsafeMutablePointer<Void>()
        if let process = resourceProgress[tag]
        {
            context = process.onDemandResourceProgressContext
        }
        return context
    }
}