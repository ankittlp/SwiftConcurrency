//
//  HeavyOperationAPI.swift
//  SwiftConcurrencyDemo
//
//  Created by Ankit on 19/12/22.
//

import Foundation


enum HeavyOperationApiError: LocalizedError {
    
    case reserveNumberError
    case diceValueIsGreaterThanRequired
}

extension Array where Element == Int  {
    
    var reducedValue: Int {
        get async throws {
            return await Task {
                self.reduce(0) { partialResult, i in
                    partialResult + i
                }
            }.value
        }
    }
}

extension Int {
    
    static var randomPakkaError: Int {
        
        get async throws {
            try? await Task.sleep(seconds: Double(1))
            throw HeavyOperationApiError.reserveNumberError
            
        }
    }
    
    static func randomWait(time: Int) async throws {
       try await Task {
            return try await Task.sleep(seconds:Double(time))
        }.value
    }
    
    static var random: Int {
        get async throws {
            
            
            let randomNumber = Int.random(in: 0...6)
            
            if reserveNumbers.contains(where: { reserveNum in
                return reserveNum == randomNumber
            }) {
                printWithThreadInfo(tag: "Throwing Error for random number \(randomNumber)")
                throw HeavyOperationApiError.reserveNumberError
            }
            
            
            /* Do it for testing:
             * Comment the cancellation check to enable returing of parent task only after all the task are finished
             */
            
            // Checking the task before perfing the heavy task.
            do {
                try Task.checkCancellation()
            }catch {
                printWithThreadInfo(tag: "checkCancellation -random value \(error)")
                throw error
            }
            
            let waitTime = Swift.max(3,randomNumber)
            printWithThreadInfo(tag: "Waiting for \(waitTime) sec")
            //try? await Task.sleep(seconds: Double(waitTime))
            try await Int.randomWait(time: waitTime)
            /* HARK:
             * Un comment to check if long running task is implicit awaited or not without awaiting child tasks.
             * Condition for testing `forgetDiceShot`
             */
            /*
            for i in 0...10000 {
                printWithThreadInfo(tag: "From loop  in random \(i)")
            }*/
            
            /* Do it for testing:
             * Comment the cancellation check to enable returing of parent task oonly after all the task are finished
             */
            
            // Checking for cancellation after the suspention is relived.
            do {
                try Task.checkCancellation()
            }catch {
                printWithThreadInfo(tag: "checkCancellation after sleep -random value \(error)")
                throw error
            }
            
            return randomNumber
        }
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

class HeavyOperationApi {
    
    private let sleepTime: UInt64 = 10
    
    static let shared = HeavyOperationApi()
    
    private init() {}
    
    func heavyNumberArray(from: Int, to: Int) -> [Int] {
        
        var number: [Int] = []
        for i in from...to {
            number.append(i)
            printWithThreadInfo(tag: "Appending \(i)")
        }
        
        return number
    }
    
    func heavyNumberArray(from: Int, to: Int, completion:  @escaping /*@Sendable*/ ([Int]) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            var number: [Int] = []
            for i in from...to {
                number.append(i)
            }
            
            completion(number)
        }
    }
   
    
    func heavyNumberArray(from: Int, to: Int) async throws -> [Int] {
        
        printWithThreadInfo(tag: "From heavyNumberArray- before sleep")
        try await Task.sleep(nanoseconds: sleepTime * 1_000_000_000)
        printWithThreadInfo(tag: "From heavyNumberArray- after sleep")
        try Task.checkCancellation()
        
        var number: [Int] = []
        for i in from...to {
            
            try Task.checkCancellation()
            if reserveNumbers.contains(where: { reserveNum in
                return reserveNum == i
            }) {
                throw HeavyOperationApiError.reserveNumberError
            }
            number.append(i)
            printWithThreadInfo(tag: "Appending \(i)")
        }
        
        printWithThreadInfo(tag: "From heavyNumberArray")
        return number
    }
    
    func heavyNumberArrayWithUnstructuredTask(from: Int, to: Int) async throws -> [Int] {
        
        try await Task.sleep(nanoseconds: sleepTime * 1_000_000_000)
        
        let numberTask = Task { () -> [Int] in
            
            try Task.checkCancellation()
            
            var number: [Int] = []
            for i in from...to {
                
                try Task.checkCancellation()
                if reserveNumbers.contains(where: { reserveNum in
                    return reserveNum == i
                }) {
                    throw HeavyOperationApiError.reserveNumberError
                }
                number.append(i)
                printWithThreadInfo(tag: "Appending \(i)")
                
                
            }
            return number
        }
        
        printWithThreadInfo(tag: "From heavyNumberArrayWithTask")
        
        return try await numberTask.value
    }
    
    @available(*, renamed: "heavyFilterEvenNumberFrom(arrayOf:)")
    func heavyFilterEvenNumberFrom(arrayOf numbers: [Int], completion:  @escaping /*@Sendable*/ ([Int]) -> Void ) {
        Task {
            let result = await heavyFilterEvenNumberFrom(arrayOf: numbers)
            completion(result)
        }
    }
    
    
    func heavyFilterEvenNumberFrom(arrayOf numbers: [Int]) async -> [Int] {
        
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                
                continuation.resume(returning: numbers.filter { number in
                    number % 2 == 0
                })
            }
        }
    }
    
    func heavyRandomMapping<T>(arrayOf numbers: [Int], transform: @escaping @Sendable (Int) -> T, completion:  @escaping @Sendable ([T]) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            completion(numbers.map { number in
                transform(number)
            })
        }
        
    }
    
    // The async version
    func heavyRandomMapping<T>(arrayOf numbers: [Int], transform: @escaping @Sendable (Int) -> T) async -> [T] {
        
        return await Task {
            let x = numbers.map { number in
                
                return transform(number)
            }
            return x
        }.value
    }
   
    
    
    
    
}


