//
//  ViewController.swift
//  SwiftConcurrencyDemo
//
//  Created by Ankit on 29/09/22.
//

import UIKit

class AsyncAwaitViewController2: UIViewController {
    @IBOutlet weak var mainActorSwitch: UISwitch!
    let name: String = "Ankit"
    let label: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
       
        /*
        print("Before callback task")
        someHeavyAsynchronousCallBackTask { [weak self] numbers in
            guard let self else { return }
            printWithThreadInfo(tag: "someHeavyAsynchronousCallBackTask - call back \(self.name)")
            
        }
        print("after callback task")
        */
        
        printWithThreadInfo(tag: "Before heavyTask task")
       //AsyncAwaitViewModel().runTwoParallelTasks()
        
//        Task {
//
//            let number = await AsyncAwaitViewModel().someHeavyAsynchronousConcurrencyIsolatedTask(start: 1, end: 1000)
//
//        }
//
        
        
        self.label.updateText(textS: "")
        Task {
            do {

                let number = try await self.someHeavyAsynchronousConcurrencyIsolatedTask(start: 5, end: 200)
                print("Number -> \(number)")
                await self.label.updateText(textS: "")
                self.label.text = "from asychronousApiCallbackType"
            } catch {
                print("Request failed with error: \(error)")
            }
        }
        
//        DispatchQueue(label: "s").async { [self] in
//            Task {
//                printWithThreadInfo(tag: "Inside Task")
//                label.text = ""
//            }
//        }
        
//        let apiTask = Task {
//            do {
//
//                printWithThreadInfo(tag: "Inside Task")
//                let data = try await asychronousCall()
//                    print(data)
//
//                } catch {
//                    print("Request failed with error: \(error)")
//                }
//        }
//        printWithThreadInfo(tag: "After  heavyTask task")
//        apiTask.cancel()
        
        
//        let heavyTask = Task { [self] in
//            do {
//
//                printWithThreadInfo(tag: "Inside Task")
//                let data = try await AsyncAwaitViewModel().someHeavyAsynchronousConcurrencyIsolatedTask(start: 100, end: 2000)
//                    //print(data)
//
//                } catch {
//                    print("Request failed with error: \(error)")
//                }
//        }
//        printWithThreadInfo(tag: "After  heavyTask task")
        //heavyTask.cancel()
        
        
//        for i in 1...90000 {
//            printWithThreadInfo(tag: "\(i)")
//        }
        
//        asychronousApiCallbackType {_ in
//
//        }
        
        
//        Task {
//            printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - Call site")
//            await someHeavyAsynchronousConcurrencyTask(start: 1, end: 1000)
//        }
        
    }
    
    func someHeavySynchronousTask() -> [Int] {
        var number: [Int] = []
        for i in 1...1000 {
            number.append(i)
        }
        printWithThreadInfo(tag: "someHeavySynchronousTask")
        return number
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
        let number = await Task.detached { () -> [Int] in
            printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - inside Task start")
            var number: [Int] = []
            for i in start...end {
                number.append(i)
            }
            printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - inside Task before return")
           /* if used detached task
            await MainActor.run(body: {
                self.label.text = "from asychronousApiCallbackType"
            })*/
            
            return number
        }.value
        // 3 Once Task is complete, suspension is revoked and it is to notice that OS may resume on any other arbitary thread other then which starts the task.
        
        printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - after await")
        return  number
    }
    
    // 1 Defined a heavy task asynchronous function with `async`
    func someHeavyAsynchronousConcurrencyIsolatedTaskWithError(start:Int, end: Int) async throws -> [Int] {
        
        printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - Start")
        // 2 create a task to start the heavy operation. Using try await here creats a suspension point where the control of thread is passed back to OS to perform some other important task. While our function is waiting for Task to get complete. And as this task may throw error we use try.
        let number = try await Task { () -> [Int] in
            printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - inside Task start")
            var number: [Int] = []
            // 3 Throwing the error if the start number is 5. Just for demonstration of error handling.
            if start == 5 {
                throw NSError(domain: "StartPointError", code: -100)
            }
            for i in start...end {
                number.append(i)
            }
            
            self.label.text = "from asychronousApiCallbackType"
            printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - inside Task before return")
            
            return number
        }.value
        // 3 Once Task is complete, suspension is revoked and it is to notice that OS may resume on any other arbitary thread other then which starts the task.
        printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - after await")
        return  number
    }
    
    // 1 - defined async heavy task
    nonisolated
    func someHeavyAsynchronousConcurrencyTask(start:Int, end: Int) async -> [Int] {
        
        printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - Start")
        let numbertask = await Task { () -> [Int] in
            printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - inside Task start")
            
            //try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
            var number: [Int] = []
            for i in start...end {
                number.append(i)
            }
            printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - inside Task before return")
            
            return number
        }.value
        printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - after await")
        
        return  numbertask
    }

    
    /*
     
     do {
         try Task.checkCancellation()
     }catch {
         print("Check checkCancellation 1- \(error.localizedDescription)")
     }
     
     do {
         try Task.checkCancellation()
     }catch {
         print("Check checkCancellation 2- \(error.localizedDescription)")
     }
     
     let url = URL(string: "https://itunes.apple.com/search?term=taylor+swift&entity=album")!

        // Use the async variant of URLSession to fetch data
        // Code might suspend here
    let (data, _) = try! await URLSession.shared.data(from: url)
     print(data)
     printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - Task.isCancelled - \(Task.isCancelled)")
     */
    
    func asychronousApiCall() async throws -> Data {
        let dataTask = Task { () -> Data in 
            
             let url = URL(string: "https://www.stackoverflow.com")!

                // Use the async variant of URLSession to fetch data
                // Code might suspend here
            printWithThreadInfo(tag: "before await in api call")
//            do {
//                try Task.checkCancellation()
//            }catch {
//                print("Check checkCancellation 1- \(error.localizedDescription)")
//                throw error
//            }
            let (data, _) = try await URLSession.shared.data(from: url)
            printWithThreadInfo(tag: "After await in api call")
        
            return data
        }
        //await Task.sleep(20 * 1_000_000_000)
        
        do {
            try Task.checkCancellation()
        }catch {
            print("Check checkCancellation 2- \(error.localizedDescription)")
            
            dataTask.cancel()
        }
        
        printWithThreadInfo(tag: "Before returning asychronousApiCall")
        return try await dataTask.value
    }
    
    func asychronousApiCallbackType(_ completion: (Result<Data,Error>) -> Void)  {
        let url = URL(string: "https://www.stackoverflow.com")!
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] responseData, urlResponse, error in
            self?.label.text = "from asychronousApiCallbackType"
        }
        task.resume()
    }
    
    func asychronousCall() async throws -> [Int] {
        /*let dataTask = Task {
            
             let url = URL(string: "https://www.stackoverflow.com")!

                // Use the async variant of URLSession to fetch data
                // Code might suspend here
            printWithThreadInfo(tag: "before await in api call")
//            do {
//                try Task.checkCancellation()
//            }catch {
//                print("Check checkCancellation 1- \(error.localizedDescription)")
//                throw error
//            }
            let (data, _) = try await URLSession.shared.data(from: url)
            printWithThreadInfo(tag: "After await in api call")
        
            return data
        }*/
        //await Task.sleep(20 * 1_000_000_000)
        
         let taskValue = try await HeavyOperationApi.shared.heavyNumberArray(from: 100, to: 2000)
        do {
            try Task.checkCancellation()
        }catch {
            print("Check checkCancellation 2- \(error.localizedDescription)")
            
           // dataTask.cancel()
        }
        
        printWithThreadInfo(tag: "Before returning asychronousApiCall")
        return   taskValue
    }
    
    func heavyNumberArray(from: Int, to: Int) async throws -> [Int] {
       
        try Task.checkCancellation()
        
        var number: [Int] = []
        for i in from...to {
            
            try Task.checkCancellation()
            if reserveNumbers.contains(where: { reserveNum in
                return reserveNum == i
            }) {
                throw NSError()
            }
            number.append(i)
            printWithThreadInfo(tag: "Appending \(i)")
        }
        
        return number
    }
}

