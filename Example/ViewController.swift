//
//  ViewController.swift
//  Example
//
//  Created by 马冰垒 on 2022/11/18.
//  Copyright © 2022 bingleima@qq.com. All rights reserved.
//

import UIKit
import GlobalTimer

class ViewController: UIViewController {
    
    private let taskIds = ["Cat", "Dog", "Panda", "Dinosaur"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: -- Event Response --
    
    @IBAction func addtasksAction(_ sender: Any) {
        // Execute a task
        GlobalTimerMananger.default().executeTask(identifier: "Cat", timeInterval: 2) {
            // print 🐱 every 1 second
            debugPrint(Date(), "🐱")
        }
        
        GlobalTimerMananger.default().executeTask(identifier: "Dog", timeInterval: 1) {
            // print 🐶 every 2 second
            debugPrint(Date(),"🐶")
        }
        
        let task1 = TimerTask(identifier: "Panda", timeInterval: 3, repeats: true) {
            // print 🐼 every 3 second
            debugPrint(Date(), "🐼")
        }
        
        let task2 = TimerTask(identifier: "Dinosaur", timeInterval: 4, repeats: true) {
            // print 🦖 every 4 second
            debugPrint(Date(), "🦖")
        }
        
        // Execute multiple tasks at once
        GlobalTimerMananger.default().executeTasks([task1, task2])
        
        // Execute a once-time task
        GlobalTimerMananger.default().executeTask(identifier: "This this a once-time task", timeInterval: 3, repeats: false) {
            debugPrint(Date(), "This this a once-time task")
        }
        
        // Get all added tasks
        let tasks = GlobalTimerMananger.default().tasks
        debugPrint("all tasks: \(tasks)")
    }
    
    @IBAction func resumeTasksAction(_ sender: Any) {
        debugPrint("\(NSDate()) resumeTasks")
        taskIds.forEach { id in
            // Resume a task with identifier
            GlobalTimerMananger.default().resumeTask(identifier: id)
        }
    }
    
    @IBAction func suspendTasksAction(_ sender: Any) {
        debugPrint("\(NSDate()) suspendTasks")
        taskIds.forEach { id in
            // Suspend a task with identifier
            GlobalTimerMananger.default().suspendTask(identifier: id)
        }
    }
    
    @IBAction func cancelTasksAction(_ sender: Any) {
        debugPrint("\(NSDate()) cancelTasks")
        taskIds.forEach { id in
            // Cancel a task with identifier
            GlobalTimerMananger.default().cancelTask(identifier: id)
        }
    }
}

