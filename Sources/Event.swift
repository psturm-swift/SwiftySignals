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

    private var connectedSlots = [InternalSlot<Message>]()
    public private(set) var lastMessage: Message? = nil
    
    public init() {
    }
    
    public func filter(_ predicate: @escaping (Message)->Bool) -> FilteredEvent<Message> {
        return FilteredEvent(event: self, predicate: predicate)
    }

    private func add(_ slot: InternalSlot<Message>) {
        connectedSlots.append(slot)
        if let lastMessage = self.lastMessage {
            slot.invoke(with: lastMessage)
        }
    }

    public func then(
        with context: InvocationContext,
        call function: @escaping (Message)->Void) -> Slot<Message>
    {
        let slot = InternalSlot<Message>(context: context, receiver: self, function: function)
        add(slot)
        return Slot(internalSlot: slot)
    }
    
    @discardableResult public func then<Receiver:AnyObject>(
        with context: InvocationContext,
        and receiver: Receiver,
        call function: @escaping (Receiver, Message) -> Void) -> Slot<Message>
    {
        let slot = InternalSlot<Message>(context: context, receiver: receiver, function: { 
            [weak receiver] message in
            if let receiver = receiver {
                function(receiver, message)
            }
        })
        add(slot)
        return Slot(internalSlot: slot)
    }
    
    public var subscriberCount: Int {
        return connectedSlots.count
    }
    
    internal func fire(with message: Message) {
        let validSlots = self.connectedSlots.filter { slot in slot.isValid }
        lastMessage = message
        for slot in validSlots {
            slot.invoke(with: message)
        }
        self.connectedSlots = validSlots
    }
    
    internal func fire(_ message: Message) {
        fire(with: message)
    }
}

public final class FilteredEvent<Message>: EventType, FilteredEventType {
    internal let predicate: (Message)->Bool
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
    
    public func then(
        with context: InvocationContext,
        call function: @escaping (Message)->Void) -> Slot<Message>
    {
        return event.then(with: context, call: function)
    }
    
    @discardableResult public func then<Receiver:AnyObject>(
        with context: InvocationContext,
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
