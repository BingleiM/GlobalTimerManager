//
//  TimerTask.swift
//  HiPOSHD_iPad
//
//  Created by 马冰垒 on 2022/8/9.
//  Copyright © 2022 bingleima@qq.com. All rights reserved.
//

import Foundation

public class TimerTask: NSObject {
    /// identifier 需要保证全局唯一
    var identifier: String
    /// 任务执行时间间隔
    var timeInterval: UInt
    /// 是否重复
    var repeats: Bool
    /// 是否被暂停
    var suspended: Bool = false
    var createdAt: UInt = 0
    /// 回调始终在 mainQueue, 外部调用时不需要切换到主线程
    var eventHandler: (() -> Void)
    
    override public var description: String {
        return "<\(Self.self), identifier: \(identifier), timeInterval: \(timeInterval), repeats: \(repeats), createdAt: \(createdAt)>\n"
    }
    
    public init(identifier: String,
                timeInterval: UInt = 0,
                repeats: Bool = true,
                eventHandler: @escaping (() -> Void)) {
        self.identifier = identifier
        self.timeInterval = timeInterval
        self.repeats = repeats
        self.eventHandler = eventHandler
    }
    
    static func ==(lhs: TimerTask, rhs: TimerTask) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
