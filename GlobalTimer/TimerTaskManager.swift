//
//  TimerTaskMananger.swift
//  HiPOSHD_iPad
//
//  Created by 马冰垒 on 2022/8/9.
//  Copyright © 2022 bingleima@qq.com. All rights reserved.
//

import Foundation

@objcMembers
class TimerTaskManager: NSObject {
    /// 所有任务
    @Protected([:])
    dynamic private(set) var tasks: [String: TimerTask]
    /// 任务最大时间间隔
    @Protected(0)
    private(set) var taskMaxTimeInterval: UInt
    /// 任务执行的最大公约数, 例如添加进来2个任务，分别是 2s 和 3s, 则 taskGCDTimeInterval 为 1
    var taskGCDTimeInterval: UInt {
        return gcdTimeIntervalOfTasks()
    }
    
    public func taskIdentifiers() -> [String] {
        return tasks.values.map { $0.identifier }
    }
    
    private func gcdTimeIntervalOfTasks() -> UInt {
        let intervals = tasks.values.map { $0.timeInterval }
        return GCD.gcd(intervals)
    }
    
    /// 添加多个任务
    /// - Parameter tasks: 任务
    public func addTasks(_ tasks: [TimerTask]) {
        guard tasks.count > 0 else { return }
        tasks.forEach { addTask($0) }
    }
    
    /// 添加单个任务
    /// - Parameter task: 任务
    public func addTask(_ task: TimerTask) {
        guard task.identifier.count > 0 else {
            print("Task id can not be empty")
            return
        }
        if let _ = tasks[task.identifier] {
            // 已存在相同 taskId, 覆盖之前任务
//            debugPrint("TaskIdentifier: \(task.identifier) already exists, overwrite the previous task")
        }
        tasks[task.identifier] = task
        taskMaxTimeInterval = task.timeInterval > taskMaxTimeInterval ? task.timeInterval : taskMaxTimeInterval
    }
    
    /// 取消某个任务
    /// - Parameter identifier: 任务 id
    public func cancelTask(identifier: String) {
        tasks.removeValue(forKey: identifier)
        taskMaxTimeInterval = tasks.values.sorted { $0.timeInterval > $1.timeInterval }.first?.timeInterval ?? 0
    }
    
    /// 暂停某个任务
    /// - Parameter identifier: 任务 id
    public func suspendTask(identifier: String) {
        if let task = tasks[identifier] {
            task.suspended = true
            tasks[identifier] = task
        }
    }
    
    /// 恢复某个任务
    /// - Parameter identifier: 任务 id
    public func resumeTask(identifier: String) {
        if let task = tasks[identifier] {
            task.suspended = false
            tasks[identifier] = task
        }
    }
        
    /// 执行任务
    /// - Parameter repeatCount: 定时器计数
    public func executeTask(repeatCount: UInt) {
        guard tasks.count > 0 else { return }
        tasks.forEach { (taskId, task) in
            guard task.suspended == false else { return }
            if (repeatCount - task.createdAt) % task.timeInterval == 0 {
                // task 的回调始终在 MainQueue 中
                if Thread.isMainThread {
                    task.eventHandler()
                } else {
                    DispatchQueue.main.async {
                        task.eventHandler()
                    }
                }
                // 一次性的任务执行完回调后, 直接丢弃
                if task.repeats == false {
                    cancelTask(identifier: task.identifier)
                }
            }
        }
    }
}
