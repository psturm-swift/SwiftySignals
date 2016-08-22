//
//  Event.swift
//  SwiftySignals
//
//  Created by Patrick Sturm on 19.08.16.
//  Copyright © 2016 Patrick Sturm. All rights reserved.
//

import Foundation

public final class Event<Message>: EventType, FilteredEventType {
    public typealias FilterResult = FilteredEvent<Message>

    private var connectedSlots = [Slot<Message>]()
    public private(set) var lastMessage: Message? = nil
    
    public init() {
    }
    
    public func filter(_ predicate: @escaping (Message)->Bool) -> FilteredEvent<Message> {
        return FilteredEvent(event: self, predicate: predicate)
    }
    
    @discardableResult public func then<Receiver:AnyObject>(with context: InvocationContext,
                     and receiver: Receiver,
                         call function: @escaping (Receiver, Message) -> Void) -> Slot<Message>
    {
        let slot = Slot<Message>(context: context, receiver: receiver, function: { [weak receiver] message in
            if let receiver = receiver {
                function(receiver, message)
            }
        })
        connectedSlots.append(slot)
        if let lastMessage = self.lastMessage {
            slot.invoke(with: lastMessage)
        }
        
        return slot
    }
    
    public var subscriberCount: Int {
        return connectedSlots.count
    }
    
    internal func fire(with message: Message) {
        lastMessage = message
        removeInvalidSlots()
        
        let connectedSlots = self.connectedSlots
        for slot in connectedSlots {
            slot.invoke(with: message)
        }
    }
    
    internal func fire(_ message: Message) {
        fire(with: message)
    }
    
    internal func removeInvalidSlots() {
        connectedSlots = connectedSlots.filter { slot in slot.isValid }
    }
}

public final class FilteredEvent<Message>: EventType, FilteredEventType {
    internal let predicate: @escaping (Message)->Bool
    internal let event: Event<Message>
    
    internal init(event: Event<Message>, predicate: @escaping (Message)->Bool) {
        self.event = event
        self.predicate = predicate
    }
    
    public func filter(_ predicate: @escaping (Message)->Bool) -> FilteredEvent<Message> {
        let currentPredictate = self.predicate
        return FilteredEvent(event: self.event, predicate: {
            message in
            return currentPredictate(message) && predicate(message)
        })
    }
    
    @discardableResult public func then<Receiver:AnyObject>(with context: InvocationContext,
                     and receiver: Receiver,
                         call function: @escaping (Receiver, Message) -> Void) -> Slot<Message>
    {
        return event.then(with: context, and: receiver) { [predicate] (receiver, message) in
            if (predicate(message)) {
                function(receiver, message)
            }
        }
    }
}
