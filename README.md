# GlobalTimerMananger
### 1. Execute Tasks
#### 1.1 Single task

```swift
// Execute a task
GlobalTimerMananger.default().executeTask(identifier: "Cat", timeInterval: 2) {
    // Add code what you want to repeat here
    // print 🐱 every 1 second
    debugPrint(Date(), "🐱")
}
```
#### 1.2 Multiple tasks

```swift
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
```
#### 1.3 Execute a once-time task
```swift
// Execute a once-time task
GlobalTimerMananger.default().executeTask(identifier: "This this a once-time task", timeInterval: 3, repeats: false) {
    debugPrint(Date(), "This this a once-time task")
}
```

### 2. Get all tasks
```swift
// Get all added tasks
let tasks = GlobalTimerMananger.default().tasks
debugPrint("all tasks: \(tasks)")
```
### 3. Suspend Tasks
```swift
// Suspend a task with identifier
GlobalTimerMananger.default().suspendTask(identifier: "Panda")
```
### 4. Resume Task
```swift
// Resume a task with identifier
GlobalTimerMananger.default().resumeTask(identifier: "Panda")
```
### 5. Cancel Task
```swift
// Cancel a task with identifier
GlobalTimerMananger.default().cancelTask(identifier: "Panda")
```
