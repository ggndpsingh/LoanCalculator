//
//  Calculator.swift
//  LoanCalculator
//
//  Created by Gagandeep Singh on 10/2/21.
//

import Foundation

struct Calculator {
    static func calculateTotalLoanRepayment(on amount: Double, over duration: Int, at interestRate: Double, frequency: Int) -> Double {
        let L = amount
        let n = Double(duration * frequency)
        let c = interestRate / frequency.doubleValue / 100

        return (L * c * n) / (1 - pow(1 + c, -n))
    }

    static func calculatePayment(on amount: Double, over duration: Int, at interestRate: Double, frequency: RepaymentFrequency) -> Double {
        let L = amount
        let n = Double(duration * 12)
        let c = interestRate / 12 / 100

        return (L * (c * pow(1 + c, n))) / (pow(1 + c, n) - 1) * 12 / frequency.rawValue.doubleValue
    }

    static func calculateRemainingBalanceAfter(period: Int, on amount: Double, over duration: Int, at interestRate: Double, frequency: RepaymentFrequency) -> Double {
        let p = Double(period * frequency.rawValue)
        let L = amount
        let n = Double(duration * frequency.rawValue)
        let c =  interestRate / frequency.rawValue.doubleValue / 100

        return (L * (pow(1 + c, n) - pow(1 + c, p))) / (pow(1 + c, n) - 1)
    }
}
