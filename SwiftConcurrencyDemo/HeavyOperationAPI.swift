//
//  HeavyOperationAPI.swift
//  SwiftConcurrencyDemo
//
//  Created by Ankit on 19/12/22.
//

import Foundation

enum HeavyOperationApiError: LocalizedError {
    case reserveNumberError
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


