//
//  AsyncAwaitVM.swift
//  SwiftConcurrencyDemo
//
//  Created by Ankit on 20/12/22.
//

import Foundation

class AsyncAwaitVM {
    
    
    /// HeavyTask - Synchronous
    /// - Returns: numbers
    func someHeavySynchronousTask() -> [Int] {
        let numbers = HeavyOperationApi.shared.heavyNumberArray(from: 10, to: 500)
        printWithThreadInfo(tag: "someHeavySynchronousTask")
        return numbers
    }
    
    func someHeavyAsynchronousCallBackTask(start: Int, end: Int, completionHandler: @escaping ([Int]) -> Void) {
        printWithThreadInfo(tag: "someHeavyAsynchronousCallBackTask - Start")
        
        HeavyOperationApi.shared.heavyNumberArray(from: start, to: end) { numbers in
            completionHandler(numbers)
        }
        
        printWithThreadInfo(tag: "someHeavyAsynchronousCallBackTask - End")
        
        
    }
    
    // 1 Defined a heavy task asynchronous function with `async` `throws`
    func someHeavyAsynchronousConcurrencyTask(start:Int, end: Int) async throws -> [Int] {
        
        printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - Start from \(start)")
        // 2 create a task to start the heavy operation. Using await here creats a suspension point where the control of thread is passed back to OS to perform some other important task. While our function is waiting for Task to get complete.
        let number = try await HeavyOperationApi.shared.heavyNumberArray(from: start, to: end)
        // 3 Once Task is complete, suspension is revoked and it is to notice that OS may resume on any other arbitary thread not just the thread which starts the task.
        printWithThreadInfo(tag: "someHeavyAsynchronousConcurrencyTask - after await \(start)")
        return  number
    }
    
    /// func with multiple operation
    /// - Parameters:
    ///   - start: start number
    ///   - end: end number
    ///   - completionHandler: A closure for coompletion
    @available(*, renamed: "multipleHeavyAsynchronousCallBackTask(start:end:)")
    func multipleHeavyAsynchronousCallBackTask(start: Int, end: Int, completionHandler: @escaping ([Int]) -> Void) {
        //1. Gets the array of numbers (A dummy heavy operation)
        HeavyOperationApi.shared.heavyNumberArray(from: start, to: end) { numbers in
            //2. Using the numbers array to fillter for Even number (A Dummy heavy operation)
            HeavyOperationApi.shared.heavyFilterEvenNumberFrom(arrayOf: numbers) { evenNumbers in
                // 3. Doing Random mapping of even numbers array (A Dummy Heavy operation)
                HeavyOperationApi.shared.heavyRandomMapping(arrayOf: evenNumbers) { number in
                    return number + 10000000
                } completion: { transformedNumbrs in
                    completionHandler(transformedNumbrs)
                }

            }
        }
    }
    
    func multipleHeavyAsynchronousAsyncTask(start: Int, end: Int) async -> Int {
        // 1 Gets the array of numbers (A dummy heavy operation)
        let heavyNumberArray = (try? await HeavyOperationApi.shared.heavyNumberArray(from: start, to: end))  ?? [0]
        // 2 Using the numbers array to fillter for Even number (A Dummy heavy operation)
        let heavyFilterEvenNumberFrom = await HeavyOperationApi.shared.heavyFilterEvenNumberFrom(arrayOf: heavyNumberArray)
        // 3 Doing Random mapping of even numbers array (A Dummy Heavy operation)
        let heavyRandomMappingArrray = await HeavyOperationApi.shared.heavyRandomMapping(arrayOf: heavyFilterEvenNumberFrom, transform: { number in
            return number + 10000000
        })
        // 4 async thowable computed proopety
        let reducedValue = (try? await heavyRandomMappingArrray.reducedValue ) ?? 0
        // 5 return
        return  reducedValue
    }
    
    
    
}
