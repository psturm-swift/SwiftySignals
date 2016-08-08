//
//  Context.swift
//  SwiftySignals
//
//  Created by Patrick Sturm on 08.08.16.
//  Copyright © 2016 Patrick Sturm. All rights reserved.
//

import Foundation

public protocol InvocationContext {
    func invoke(function: Void->Void)
}

public struct DefaultInvocationContext: InvocationContext {
    public func invoke(function: Void -> Void) {
        if NSThread.isMainThread() {
            function()
        }
        else {
            dispatch_async(dispatch_get_main_queue()) {
                function()
            }
        }
    }
}

public struct ImmediateInvocationContext: InvocationContext {
    public func invoke(function: Void -> Void) {
        function()
    }
}

public struct DispatchQueueInvocationContext: InvocationContext {
    let dispatchQueue: dispatch_queue_t
    
    public init(dispatchQueue: dispatch_queue_t) {
        self.dispatchQueue = dispatchQueue
    }
    
    public func invoke(function: Void -> Void) {
        dispatch_async(dispatchQueue) {
            function()
        }
    }
}
