//
//  Calculator.swift
//  LoanCalculator
//
//  Created by Gagandeep Singh on 10/2/21.
//

import Foundation

struct Calculator {
    static func calculateTotalLoanRepayment(on amount: Double, over duration: Int, at interestRate: Double) -> Double {
        let L = amount
        let n = Double(duration * 12)
        let c = interestRate / 12 / 100

        return (L * c * n) / (1 - pow(1 + c, -n))
    }

    static func calculateMonthlyPayment(on amount: Double, over duration: Int, at interestRate: Double) -> Double {
        let L = amount
        let n = Double(duration * 12)
        let c = interestRate / 12 / 100

        return (L * (c * pow(1 + c, n))) / (pow(1 + c, n) - 1)
    }

    static func calculateRemainingBalanceAfter(period: Int, on amount: Double, over duration: Int, at interestRate: Double) -> Double {
        let p = Double(period * 12)
        let L = amount
        let n = Double(duration * 12)
        let c =  interestRate / 12 / 100

        return (L * (pow(1 + c, n) - pow(1 + c, p))) / (pow(1 + c, n) - 1)
    }
}
