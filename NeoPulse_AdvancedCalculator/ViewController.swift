//
//  ViewController.swift
//  NeoPulse_AdvancedCalculator
//
// Created by the NEOPULSE team on 11/19/25.
// COLLO, PAUL BENEDICT V.
// CUETO, ALEXA JOYCE G.
// PUA, CHARLES MICHAEL G.
// WEI, WENXUAN

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var displayLabel: UILabel!
    
    var currentNumber = "0"
    var previousNumber: Double = 0
    var operation: String?
    var isTypingNumber = false
    var shouldResetDisplay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayLabel.text = currentNumber
        setupDisplayLabel()
    }
    
    func setupDisplayLabel() {
        displayLabel.adjustsFontSizeToFitWidth = true
        displayLabel.minimumScaleFactor = 0.5
        displayLabel.numberOfLines = 1
        displayLabel.textAlignment = .right
        displayLabel.baselineAdjustment = .alignCenters
    }
    
    //button connections
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if let value = sender.currentTitle {
            print("Number button tapped: \(value)")
            if value == "." {
                addDecimal()
            } else {
                handleNumber(value)
            }
        } else if let title = sender.titleLabel?.text {
            print("Button tapped via titleLabel: \(title)")
            if title == "." {
                addDecimal()
            } else {
                handleNumber(title)
            }
        } else {
            print("Button has no title")
        }
    }
    
    //operations connections
    
    @IBAction func operationTapped(_ sender: UIButton) {
        if let value = sender.currentTitle {
            print("Operation button tapped: \(value)")
            handleOperation(value)
        } else if let title = sender.titleLabel?.text {
            print("Operation button tapped via titleLabel: \(title)")
            handleOperation(title)
        } else {
            print("Operation button has no title")
        }
    }
    
    //operation function
    
    func handleOperation(_ op: String) {
        guard let displayText = displayLabel.text else { return }

        if isTypingNumber && operation != nil {
            calculateResult()
        }
        
        let currentDisplayNumber = getCurrentNumberFromDisplay()
        previousNumber = Double(currentDisplayNumber) ?? 0
        operation = op
        isTypingNumber = false
        currentNumber = "0"
        
        //to display the number and operation
        displayLabel.text = "\(formatNumber(previousNumber)) \(op)"
    }
    
    //current number function
    
    func getCurrentNumberFromDisplay() -> String {
        //the current number from display
        if let op = operation, let range = displayLabel.text?.range(of: " \(op) ") {
            //shows full equation
            let lastPart = String(displayLabel.text![range.upperBound...])
            return lastPart.trimmingCharacters(in: .whitespaces)
        }
        return currentNumber
    }
    
    //equal connection
    
    @IBAction func equalTapped(_ sender: UIButton) {
        print("Equal button tapped")
        calculateResult()
    }
    
    //clear connection
    @IBAction func clearTapped(_ sender: UIButton) {
        print("Clear button tapped")
        clearAll()
    }
    
    //toggle sign connection
    @IBAction func toggleSignTapped(_ sender: UIButton) {
        print("Toggle sign button tapped")
        toggleSign()
    }
    
    //percent connection
    @IBAction func percentTapped(_ sender: UIButton) {
        print("Percent button tapped")
        applyPercent()
    }
}

extension ViewController {
    
    func handleNumber(_ num: String) {
        print("Handling number: \(num), isTypingNumber: \(isTypingNumber), currentNumber: \(currentNumber)")
        
        //clear everything
        if shouldResetDisplay {
            clearAll()
            shouldResetDisplay = false
        }
        
        if isTypingNumber {
            //multiple leading zeros
            if currentNumber == "0" && num != "." {
                currentNumber = num
            } else {
                currentNumber += num
            }
        } else {
            currentNumber = num
            isTypingNumber = true
        }
        
        //display based on whether we have an operation
        updateDisplay()
    }
    
    func addDecimal() {
        print("Adding decimal, currentNumber: \(currentNumber)")
        
        if shouldResetDisplay {
            clearAll()
            shouldResetDisplay = false
        }
        
        if !isTypingNumber {
            currentNumber = "0."
            isTypingNumber = true
        } else if !currentNumber.contains(".") {
            currentNumber += "."
        }
        
        updateDisplay()
    }
    
    func updateDisplay() {
        if let op = operation, isTypingNumber {
            displayLabel.text = "\(formatNumber(previousNumber)) \(op) \(currentNumber)"
        } else if let op = operation, !isTypingNumber {
            displayLabel.text = "\(formatNumber(previousNumber)) \(op)"
        } else {
            displayLabel.text = currentNumber
        }
    }
    
    func calculateResult() {
        guard let op = operation else {
            print("No operation to calculate")
            return
        }
        
        let current = Double(currentNumber) ?? 0
        var result: Double = 0
        
        switch op {
        case "+":
            result = previousNumber + current
        case "-":
            result = previousNumber - current
        case "×":
            result = previousNumber * current
        case "÷":
            if current == 0 {
                    displayLabel.text = "Undefined"
                    operation = nil
                    isTypingNumber = false
                    shouldResetDisplay = true
                    return
            }
            result = previousNumber / current
        default:
            return
        }
        
        //result display
        currentNumber = formatNumber(result)
        
        displayLabel.text = currentNumber

        previousNumber = result
        operation = nil
        isTypingNumber = false
        shouldResetDisplay = true
        
        print("Calculation result: \(result)")
    }
    
    func clearAll() {
        currentNumber = "0"
        previousNumber = 0
        operation = nil
        isTypingNumber = false
        shouldResetDisplay = false
        displayLabel.text = "0"
    }
    
    func toggleSign() {
        if let value = Double(currentNumber) {
            currentNumber = formatNumber(value * -1)
            updateDisplay()
        }
    }
    
    func applyPercent() {
        if let value = Double(currentNumber) {
            currentNumber = formatNumber(value / 100)
            updateDisplay()
        }
    }
    
    func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6
        formatter.numberStyle = .decimal
        
        if abs(number) >= 1e10 || (abs(number) < 1e-6 && number != 0) {
            formatter.numberStyle = .scientific
            formatter.exponentSymbol = "e"
            formatter.maximumFractionDigits = 2
        }
        
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
