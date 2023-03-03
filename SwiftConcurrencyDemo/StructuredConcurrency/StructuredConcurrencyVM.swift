//
//  StructuredConcurrencyVM.swift
//  SwiftConcurrencyDemo
//
//  Created by Ankit on 29/01/23.
//

import Foundation

class StructuredConcurrencyVM {
    
    func sequentialDiceValues(forMax maxValue:Int ) async throws -> Int {
        printWithThreadInfo(tag: "sequentialDiceValues")
        var p = PingPong()
        p.ping(context: "sequentialDiceValues")
        let firstDice = try await Int.random
        let secondDice = try await Int.random
        
        let total = firstDice + secondDice
        p.pong(context: "sequentialDiceValues")
        if total > maxValue {
            throw HeavyOperationApiError.diceValueIsGreaterThanRequired
        }
        
        return total
    }
    
    func parallerDiceValues(forMax maxValue:Int ) async throws -> Int {
        
        printWithThreadInfo(tag: "parallerDiceValues")
        // Time Calculation
        var p = PingPong()
        p.ping(context: "parallerDiceValues")
        
        // first dice execute in parallel
        async let firstDice =  Int.randomPakkaError // To understand more clearly use Int.randomPakkaError, this will throw error and as we are awaiting on firstDice the task associated with secondDice will be marked cancelled and implicit awaited.
        
        // second dice execute in parallel
        
        async let secondDice = Int.random
        async let threeDice = Int.random
        // At this point we await to get the result of all the parallel executed task, Also used try as Int.random is Throwable async property.
        let totalArr =  try await [secondDice, firstDice, threeDice] // if we comment second dice in this line, it will  be implicit awaited and cancelled. read wwdc structured concurency for more  details
        let total = totalArr.reduce(0) { partialResult, x in
            return partialResult + x
        }
        p.pong(context: "parallerDiceValues")
        if total > maxValue {
            throw HeavyOperationApiError.diceValueIsGreaterThanRequired
        }
        
        return total
    }
    
    func forgetDiceShot() async -> String {
        var p = PingPong()
        p.ping(context: "forgetDiceShot")
        // never await work...
        async let firstDice =  Int.random
        // implicitly: cancels work
        // implicitly: awaits work, discards errors
        p.pong(context: "forgetDiceShot")
        return "nevermind..."
    }
    
}
