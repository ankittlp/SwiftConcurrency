//
//  StructuredConcurrencyViewController.swift
//  SwiftConcurrencyDemo
//
//  Created by Ankit on 29/01/23.
//

import UIKit

class StructuredConcurrencyViewController: UIViewController {

    lazy var structuredConcurrencyVM = StructuredConcurrencyVM()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func sequentialDiceValuesTask(_ sender: UIButton) {
        Task {
            do {
                let diceValue = try await structuredConcurrencyVM.sequentialDiceValues(forMax: 6)
                printWithThreadInfo(tag: "diceValue - \(diceValue)")
            } catch {
                printWithThreadInfo(tag: "Failed with Error \(error)")
            }
        }
    }
    
    @IBAction func parallerDiceValuesTask(_ sender: UIButton) {
        let task = Task {
            do {
                let diceValue = try await structuredConcurrencyVM.parallerDiceValues(forMax: 6)
                printWithThreadInfo(tag: "diceValue - \(diceValue)")
            } catch {
                printWithThreadInfo(tag: "Failed with Error \(error)")
            }
        }
        
        //task.cancel()
        
    }
    
    @IBAction func doNotAwaitDiceValue() {
        Task {
            var ping = PingPong()
            ping.ping(context: "doNotAwaitDiceValue")
            await structuredConcurrencyVM.forgetDiceShot()
            ping.pong(context: "doNotAwaitDiceValue")
        }
    }

}
