//
//  PingPong.swift
//  SwiftConcurrencyDemo
//
//  Created by Ankit on 03/02/23.
//

import Foundation

struct PingPong {
    
    private var pingTime: TimeInterval = Date().timeIntervalSince1970
    
    mutating func ping(context: String? = nil) {
        
        pingTime = Date().timeIntervalSince1970
        print("[Ping] \(context ?? "")")
    }
    
    mutating func pong(context: String? = nil) {
        
        let pongTime = Date().timeIntervalSince1970 - pingTime
        let formatedPongtime = String(format: "%.10f", pongTime)
        print("[Pong] \(context ?? "") - \(formatedPongtime) sec")
    }
}
