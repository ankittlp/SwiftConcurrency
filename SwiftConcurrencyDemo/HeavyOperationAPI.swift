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
    
    func heavyNumberArray(from: Int, to: Int, completion:  @escaping /*@Sendable*/ ([Int]) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            var number: [Int] = []
            for i in from...to {
                number.append(i)
            }
            
            completion(number)
        }
    }
    
    func heavyFilterEvenNumberFrom(arrayOf numbers: [Int], completion:  @escaping /*@Sendable*/ ([Int]) -> Void ) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            completion(numbers.filter { number in
                number % 2 == 0
            })
        }
    }
    
    func heavyRandomMapping<T>(arrayOf numbers: [Int], transform: @escaping @Sendable (Int) -> T, completion:  @escaping @Sendable ([T]) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            completion(numbers.map { number in
                transform(number)
            })
        }
        
    }
    
    
}


