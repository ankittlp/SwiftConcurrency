//
//  AsyncAwaitViewController1.swift
//  SwiftConcurrencyDemo
//
//  Created by Ankit on 19/12/22.
//

import UIKit

class AsyncAwaitViewController: UIViewController {

    @IBOutlet weak var mainActorSwitch: UISwitch!
    
    lazy var asyncAwaitVM = AsyncAwaitVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //multipleTaskCompletionType()
        //multipleTaskAsyncType()
        
    }
    
    
    @IBAction func switchValueChange(_ sender: UISwitch) {
    }
    
    @IBAction func syncTask(_ sender: UIButton) {
        let numbers = asyncAwaitVM.someHeavySynchronousTask()
        printWithThreadInfo(tag: "Task finished number count- \(numbers.count)")
    }
    
    @IBAction func asyncTaskCallBack(_ sender: UIButton) {
        asyncAwaitVM.someHeavyAsynchronousCallBackTask(start: 4, end: 100) { numbers in
            printWithThreadInfo(tag: "Task finished number count- \(numbers.count)")
        }
        
    }
    
    @IBAction func asyncConcurrencyTask(_ sender: UIButton) {
        
        Task {
            try? await asyncAwaitVM.someHeavyAsynchronousConcurrencyTask(start: 5, end: 100)
        }
    }
    
    
    
    @IBAction func errorHandling(_ sender: UIButton) {
        Task {
            do {
                let number = try await asyncAwaitVM.someHeavyAsynchronousConcurrencyTask(start: 4, end: 200)
                printWithThreadInfo(tag: "Task finished number count- \(number.count)")
            } catch {
                print("Task failed with error: \(error)")
            }
        }
    }
    
    @IBAction func multipleTaskCompletionType() {
        asyncAwaitVM.multipleHeavyAsynchronousCallBackTask(start: 5, end: 200) { numbers in
            printWithThreadInfo(tag: "Task finished number count- \(numbers.count)")
        }
    }
    
    @IBAction func multipleTaskAsyncType() {
        
        Task {
            let number = await asyncAwaitVM.multipleHeavyAsynchronousAsyncTask(start: 5, end: 200)
            printWithThreadInfo(tag: "Task finished reduced - \(number)")
        }
        
        
    }
    
    @IBAction func multipleTaskAsyncTypeParallel() {
        
        Task {
            await asyncAwaitVM.runTwoParallelTasks()
            printWithThreadInfo(tag: "After multipleTaskAsyncTypeParallel")
        }
        
        
    }
    
    @IBAction func multipleTaskAsyncTypeParallelDetached() {
        
        Task.detached(priority: .background) {
            await self.asyncAwaitVM.runTwoParallelTasks()
            printWithThreadInfo(tag: "After multipleTaskAsyncTypeParallel")
        }
    }
    
    @IBAction func multipleTaskAsyncTypeParallelStructured() {
        Task {
            do {
                let number = try await asyncAwaitVM.runTwoParallelTasksStructured()
                printWithThreadInfo(tag: "Task multipleTaskAsyncTypeParallelStructured finished - \(number)")
            } catch {
                print("Task failed with error: \(error)")
            }
        }
        
    }
    
    
    
    

}

extension AsyncAwaitViewController {
    
    func someHeavySynchronousTask() -> [Int] {
        
        printWithThreadInfo(tag: "someHeavySynchronousTask")
        return HeavyOperationApi.shared.heavyNumberArray(from: 1, to: 1000)
    }

    func someHeavyAsynchronousCallBackTask(_ completionHandler: ([Int]) -> Void) {
        printWithThreadInfo(tag: "someHeavyAsynchronousCallBackTask - Start")
        
        DispatchQueue.global(qos: .userInitiated).async {
            printWithThreadInfo(tag: "someHeavyAsynchronousCallBackTask - inside DispatchQueue.global async")
            DispatchQueue.global().sync {
                printWithThreadInfo(tag: "someHeavyAsynchronousCallBackTask - inside DispatchQueue.global sync")
                var number: [Int] = []
                for i in 1...1000 {
                    number.append(i)
                    printWithThreadInfo(tag: "Appending - \(i)")
                }
                
            }
        }
        printWithThreadInfo(tag: "someHeavyAsynchronousCallBackTask - after DispatchQueue.global")
        
    }
    
    // 1 Defined a heavy task asynchronous function with `async`
    func someHeavyAsynchronousConcurrencyIsolatedTask(start:Int, end: Int) async -> [Int] {
        
        printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - Start")
        // 2 create a task to start the heavy operation. Using await here creats a suspension point where the control of thread is passed back to OS to perform some other important task. While our function is waiting for Task to get complete.
        let number = await Task { () -> [Int] in
            printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - inside Task start")
            var number: [Int] = []
            for i in start...end {
                number.append(i)
            }
            printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - inside Task before return")
            
            return number
        }.value
        // 3 Once Task is complete, suspension is revoked and it is to notice that OS may resume on any other arbitary thread other then which starts the task.
        
        printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - after await")
        return  number
    }
}
