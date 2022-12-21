//
//  GlobalFunctions.swift
//  SwiftConcurrencyDemo
//
//  Created by Ankit on 19/12/22.
//

import Foundation

func printWithThreadInfo(tag: String) {
    print("Thread \(Thread.current) - \(tag) - \(Thread.isMainThread)")
}

let reserveNumbers = [4 , 3000, 5000]


