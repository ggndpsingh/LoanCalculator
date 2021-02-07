//: A UIKit based Playground for presenting user interface

import SwiftUI

class HomeLoan {
    let loanAmount: Double
    let term: Term
    let interest: Interest

    var repayments: [Double] = []
    var table: [TableRow] = []

    init(loanAmount: Double, term: Term, interest: Interest, repayments: [Double] = []) {
        self.loanAmount = loanAmount
        self.term = term
        self.interest = interest
        self.repayments = repayments

        makeRepayments()
    }

    func monthlyInterestRate(for month: Int) -> Double {
        switch interest {
        case .fixed(let val):
            return val / 12 /  100
        case .mix(let fixed, let variable):
            if month <= fixed.0 {
                return fixed.1  / 12 /  100
            }

            return variable / 12 /  100
        }
    }

    var totalLoan: Double {
        var amount: Double = 0
        for row in repayments {
            amount += row
        }
        return amount
    }

    func makeRepayments() {
        switch interest {
        case .fixed(let val):
            let rate = val / 12 / 100
            let over = loanAmount * rate * term.doubleValue
            let under = 1 - Double(truncating: NSDecimalNumber(value: pow(1 + rate, -term.doubleValue)))
            let totalLoan = over / under
            let repayment = totalLoan / term.doubleValue
            self.repayments = Array(repeating: repayment, count: term.value)
            self.table = createLoanTable(for: loanAmount, rate: rate, term: term.value, repayment: repayment)

        case .mix(let fixed, let variable):
            let fixedRate = fixed.1 / 12 / 100
            let fixedOver = loanAmount * fixedRate * term.doubleValue
            let fixedUnder = 1 - Double(truncating: NSDecimalNumber(value: pow(1 + fixedRate, -term.doubleValue)))
            let fixedTotal = fixedOver / fixedUnder
            let fixedMonthly = (fixedTotal / term.doubleValue).round(to: 2)

            self.repayments = Array(repeating: fixedMonthly, count: fixed.0)

            let remainingTerm = term.doubleValue - Double(fixed.0)

            let fixedTable = Array(createLoanTable(for: loanAmount, rate: fixedRate, term: term.value, repayment: fixedMonthly).prefix(fixed.0))
            let balance = fixedTable.last?.balance ?? 0

            let variableRate = variable / 12 / 100
            let variableOver = balance * variableRate * remainingTerm
            let variableUnder = 1 - Double(truncating: NSDecimalNumber(value: pow(1 + variableRate, -remainingTerm)))
            let variableTotal = variableOver / variableUnder

            let remaining = variableTotal
            let variableMonthly = (remaining / remainingTerm).round(to: 2)
            self.repayments.append(contentsOf: Array(repeating: variableMonthly, count: Int(remainingTerm)))

            let variableTable = createLoanTable(for: balance, rate: variableRate, term: Int(remainingTerm), repayment: variableMonthly, startIndex: fixed.0)

            var table = fixedTable
            table.append(contentsOf: variableTable)

            self.table = table
        }
    }

    func createLoanTable(for amount: Double, rate: Double, term: Int, repayment: Double, startIndex: Int = 0) -> [TableRow] {
        guard !repayments.isEmpty else { return [] }
        var balance = amount

        var index = startIndex + 1
        var table: [TableRow] = []
        for _ in 0..<term {
            let interest = balance * rate
            let newBalance = balance - repayment + interest
            balance = newBalance >= 5 ? newBalance.round(to: 2) : 0

            table.append(.init(id: index, interest: interest, repayment: repayment, balance: balance))
            index += 1
        }

        return table
    }

    struct TableRow: Identifiable {
        let id: Int
        let interest: Double
        let repayment: Double
        let balance: Double
    }
}

enum Term: CustomStringConvertible {
    case years(Int)
    case months(Int)

    var value: Int {
        switch self {
        case .months(let val):
            return val
        case .years(let val):
            return val * 12
        }
    }

    var doubleValue: Double {
        Double(value)
    }

    var description: String {
        switch self {
        case .months(let val):
            return "\(val) Months"
        case .years(let val):
            return "\(val) Years"
        }
    }
}

enum Interest {
    case fixed(Double)
    case mix((Int, Double), Double)

    init(fixed value: Double) {
        self = .fixed(value)
    }

    init(fixedTerm: Int, fixedRate: Double, variableRate: Double) {
        self = .mix((fixedTerm, fixedRate), variableRate)
    }
}

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    func roundUp(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded(.up) / divisor
    }
}
