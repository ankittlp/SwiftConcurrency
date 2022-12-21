//
//  ASyncAwaitViewModel.swift
//  SwiftConcurrencyDemo
//
//  Created by Ankit on 07/12/22.
//

import Foundation
import UIKit

 class AsyncAwaitViewModel1/*: Sendable*/ {
     var x: Person?  //= Person(firstName: "", lastName: "")
     
     let label: UILabel = UILabel()
     
     init() {
         Task {
             x = await Person(firstName: "", lastName: "")
             
             
         }
     }
    func runTwoParallelTasks() {
         
        Task {
            x = await Person(firstName: "", lastName: "")
            let number = await someHeavyAsynchronousConcurrencyIsolatedTask(start: 10, end: 300)
            
        }
        
//        Task {
//            
//            let number = await someHeavyAsynchronousConcurrencyIsolatedTask(start: 1001, end: 2000)
//            
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

    func someHeavyAsynchronousCallBackTask(start: Int, end: Int, completionHandler: @escaping ([Int]) -> Void) {
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
    
    
    func someHeavyAsynchronousConcurrencyIsolatedTask(start:Int, end: Int) async -> [Int] {
        
        printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - Start from \(start)")
        // 2 create a task to start the heavy operation. Using await here creats a suspension point where the control of thread is passed back to OS to perform some other important task. While our function is waiting for Task to get complete.
        /*let number = await Task { () -> [Int] in
            printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - inside Task start from \(start)")
            var number: [Int] = []
            for i in start...end {
               
                number.append(i)
            }
            printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - inside Task before return - \(start)")
            
            return number
        }.value*/
        let number = try? await HeavyOperationApi.shared.heavyNumberArray(from: start, to: end)
        // 3 Once Task is complete, suspension is revoked and it is to notice that OS may resume on any other arbitary thread other then which starts the task.
        
        printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - after await \(start)")
        //await updateLabeel()
        return  number ?? [0]
    }
    
//    func updateLabeel() async {
//         await MainActor.run {
//             self.label.text = "from asychronousApiCallbackType"
//         }
//
//    }
     
     
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
}


@MainActor
class Person {
    var firstName: String = ""
    var lastName: String = ""
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    func tryToPrintNameOnMainThread() {
        print("Is Main Thread: \(Thread.isMainThread)")
        print("\(firstName) \(lastName)")
    }
}


