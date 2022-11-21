//
//  GlobalTimerMananger.swift
//  HiPOSHD_iPad
//
//  Created by 马冰垒 on 2022/8/9.
//  Copyright © 2022 bingleima@qq.com. All rights reserved.
//


import Foundation

final public class GlobalTimerMananger: NSObject {
    
    private let kKeyPath = "tasks"
    private static var single = GlobalTimerMananger()
    private lazy var taskManager: TimerTaskMananger = {
        let tm = TimerTaskMananger()
        return tm
    }()
    
    private var loopTimer: DispatchSourceTimer?
    private typealias LoopTimerHandler = @convention(block) () -> Void
    /// 定时器执行次数
    @Protected(0)
    private var repeatCount: UInt
    /// 定时器是否初始化完成
    private var timerInitialized = false
    /// 定时器是否已挂起
    private var timerSuspended = false
    /// timer 调用间隔
    @Protected(1)
    private var timerRepeatInterval: UInt
    /// 获取当前定时器中已添加的任务
    public var taskIdentifiers: [String] {
        return taskManager.taskIdentifiers()
    }

    deinit {
        taskManager.removeObserver(self, forKeyPath: kKeyPath, context: nil)
        cancelLoopTimer()
    }
    
    private override init() {
        super.init()
        _setup()
        taskManager.addObserver(self, forKeyPath: kKeyPath, options: [.new], context: nil)
    }
    
    public override func copy() -> Any {
        return self
    }
    
    public override func mutableCopy() -> Any {
        return self
    }
    
    // MARK: -- Public Methods --
    public class func `default`() -> GlobalTimerMananger {
        return single
    }
    
    public class func reset() {
        single.loopTimer?.cancel()
        single.loopTimer = nil
        single = GlobalTimerMananger()
    }
    
    /// 向全局定时器中添加单个任务
    /// - Parameters:
    ///   - identifier: 任务 id, 必须全局唯一, 多次添加同一个 identifier，会覆盖掉之前的
    ///   - timeInterval: 任务调用间隔
    ///   - repeats: 是否重复
    ///   - eventHandler: 执行任务回调
    public func executeTask(identifier: String,
                            timeInterval: UInt,
                            repeats: Bool = true,
                            eventHandler: @escaping (() -> Void)) {
        _executeTask(TimerTask(identifier: identifier,
                                 timeInterval: timeInterval,
                                 repeats: repeats,
                                 eventHandler: eventHandler))
    }
    
    /// 向全局定时器中添加多个任务
    public func executeTasks(_ tasks: [TimerTask]) {
        _executeTasks(tasks)
    }
    
    /// 取消全局定时器中的某个任务
    /// - Parameter identifier: 任务 id
    public func cancelTask(identifier: String) {
        taskManager.cancelTask(identifier: identifier)
    }
    
    /// 暂停全局定时器中某个任务
    /// - Parameter identifier: 任务 id
    public func suspendTask(identifier: String) {
        taskManager.suspendTask(identifier: identifier)
    }
    
    /// 恢复全局定时器中某个任务
    /// - Parameter identifier: 任务 id
    public func resumeTask(identifier: String) {
        taskManager.resumeTask(identifier: identifier)
    }
}

// MARK: -- Private Methods --
extension GlobalTimerMananger {
    
    private func _setup() {
        activateLoopTimer(interval: timerRepeatInterval,
                       event: { [weak self] in
            self?._timerEventHandler()
        })
    }
    
    private func _timerEventHandler() {
        repeatCount = repeatCount.addingReportingOverflow(timerRepeatInterval).partialValue
        taskManager.executeTask(repeatCount: repeatCount)
    }
    
    private func _executeTask(_ task: TimerTask) {
        task.createdAt = repeatCount
        taskManager.addTask(task)
        _updateTimerIntervalIfNeeded()
    }
    
    private func _executeTasks(_ tasks: [TimerTask]) {
        taskManager.addTasks(tasks)
        _updateTimerIntervalIfNeeded()
    }
    
    private func _resume() {
        guard timerSuspended == true else { return }
        loopTimer?.resume()
        timerSuspended = false
    }
    
    private func _suspend() {
        guard timerSuspended == false else { return }
        loopTimer?.suspend()
        timerSuspended = true
    }
    
    private func _updateTimerIntervalIfNeeded() {
        if timerRepeatInterval != taskManager.taskGCDTimeInterval {
            timerRepeatInterval = taskManager.taskGCDTimeInterval
            _resetTimer()
        }
    }
    
    private func _resetTimer() {
        timerSchedule(loopTimer, interval: timerRepeatInterval)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == kKeyPath {
            if taskManager.tasks.count == 0 {
                // 无任务处理时, 挂起定时器
                _suspend()
            } else {
                // 有任务处理时, 启动定时器
                _resume()
            }
        }
    }
}

// MARK: -- Timer --
extension GlobalTimerMananger {
    
    private func activateLoopTimer(interval: UInt, event: LoopTimerHandler?) {
        guard (loopTimer == nil || loopTimer?.isCancelled == false) else { return }
        // 子线程创建timer
        let privateQueue = DispatchQueue(label: "com.timermanager.queue", attributes: .concurrent)
        loopTimer = DispatchSource.makeTimerSource(flags: [], queue: privateQueue)
        // dealine: 开始执行时间   repeating: 重复时间间隔  leeway: 时间精度 （一般重复的 Timer 至少设置10%）
        timerSchedule(loopTimer, interval: interval)
        // timer 添加事件
        loopTimer?.setEventHandler {
            event?()
        }
        loopTimer?.setRegistrationHandler(handler: { [weak self] in
            self?.timerInitialized = true
        })
        loopTimer?.resume()
    }
    
    private func timerSchedule(_ timer: DispatchSourceTimer?, interval: UInt) {
        timer?.schedule(wallDeadline: .now() + .seconds(Int(interval)),
                        repeating: .seconds(Int(interval)),
                        leeway: .seconds(Int(interval) * 10 / 100))
    }
    
    private func cancelLoopTimer() {
        guard let t = loopTimer else { return }
        t.cancel()
        loopTimer = nil
        self.timerInitialized = false
    }
}

