//
//  Protected.swift
//  GlobalTimer
//
//  Created by 马冰垒 on 2022/8/18.
//  Copyright © 2022 bingleima@qq.com. All rights reserved.
//  Reference From: http://alamofire.org/

import Foundation

private protocol Lock {
    func lock()
    func unlock()
}

extension Lock {
    func around<T>(_ closure: () throws -> T) rethrows -> T {
        lock(); defer { unlock() }
        return try closure()
    }
    
    func around(_ closure: () throws-> Void) rethrows {
        lock(); defer { unlock() }
        try closure()
    }
}

final class UnfairLock: Lock {
    
    private let unfairLock: os_unfair_lock_t
    
    init() {
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
    }
    
    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }
    
    func lock() {
        os_unfair_lock_lock(unfairLock)
    }
    
    func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }
}

@propertyWrapper
final class Protected<T> {
    
    private let lock = UnfairLock()
    private var value: T
    
    init(_ value: T) {
        self.value = value
    }
    
    var wrappedValue: T {
        get { lock.around { value } }
        set { lock.around { value = newValue } }
    }
}
