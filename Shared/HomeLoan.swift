//: A UIKit based Playground for presenting user interface

import SwiftUI

class HomeLoan {
    let loanAmount: Double
    let duration: Int
    let repayment: Repayment

    var totalDuration: Int { duration * 12 }

    var repayments: [Double] = []
    var table: [TableRow] = [] {
        didSet {
            totalInterest = table.map { $0.interest }.reduce(0, +)
            repayments = table.map { $0.repayment }
        }
    }

    var extraTable: [TableRow] = []

    var totalInterest: Double = 0

    init(loanAmount: Double, duration: Int, repayment: Repayment) {
        self.loanAmount = loanAmount
        self.duration = duration
        self.repayment = repayment

        makeRepayments()
    }

    var totalLoan: Double {
        var amount: Double = 0
        for row in repayments {
            amount += row
        }
        return amount
    }

    func makeRepayments() {
        switch repayment {
        case .standard(let val):
            let rate = val / 12 / 100
            let over = loanAmount * rate * totalDuration.doubleValue
            let under = 1 - Double(truncating: NSDecimalNumber(value: pow(1 + rate, -totalDuration.doubleValue)))
            let totalLoan = over / under
            let repayment = (totalLoan / totalDuration.doubleValue)

            let table = createLoanTable(for: loanAmount, rate: rate, term: totalDuration, repayment: repayment)
            self.table = makeTable(fixed: table)
            let extraPaymentsTable = createLoanTable(for: loanAmount, rate: rate, term: totalDuration, repayment: 3000)
            self.extraTable = makeTable(fixed: extraPaymentsTable)

        case .fixedPeriod(let term):
            let fixedRate = term.fixedRate / 12 / 100
            let fixedOver = loanAmount * fixedRate * totalDuration.doubleValue
            let fixedUnder = 1 - Double(truncating: NSDecimalNumber(value: pow(1 + fixedRate, -totalDuration.doubleValue)))
            let fixedTotal = fixedOver / fixedUnder
            let fixedMonthly = (fixedTotal / totalDuration.doubleValue)

            let remainingTerm = totalDuration.doubleValue - Double(term.totalDuration)

            let fixedTable = Array(createLoanTable(for: loanAmount, rate: fixedRate, term: totalDuration, repayment: fixedMonthly).prefix(term.totalDuration))
            let balance = fixedTable.last?.balance ?? 0

            let variableRate = term.variableRate / 12 / 100
            let variableOver = balance * variableRate * remainingTerm
            let variableUnder = 1 - Double(truncating: NSDecimalNumber(value: pow(1 + variableRate, -remainingTerm)))
            let variableTotal = variableOver / variableUnder

            let remaining = variableTotal
            let variableMonthly = (remaining / remainingTerm)

            let variableTable = createLoanTable(for: balance, rate: variableRate, term: Int(remainingTerm), repayment: variableMonthly, startIndex: term.totalDuration)

            self.table = makeTable(fixed: fixedTable, variable: variableTable)

            let fixedExtraTable = Array(createLoanTable(for: loanAmount, rate: fixedRate, term: totalDuration, repayment: 3000).prefix(term.totalDuration))
            let variableExtraTable = createLoanTable(for: fixedExtraTable.last?.balance ?? 0, rate: variableRate, term: Int(remainingTerm), repayment: 3000, startIndex: term.totalDuration)

            self.extraTable = makeTable(fixed: fixedExtraTable, variable: variableExtraTable)
        }
    }

    private func makeTable(fixed: [TableRow], variable: [TableRow] = []) -> [TableRow] {
        var table = [TableRow(id: 0, interest: 0, repayment: 0, balance: loanAmount)]
        table.append(contentsOf: fixed + variable)
        return table
    }

    func createLoanTable(for amount: Double, rate: Double, term: Int, repayment: Double, startIndex: Int = 0) -> [TableRow] {
        var balance = amount
        var payment = repayment

        var index = startIndex + 1
        var table: [TableRow] = []
        while balance > 5 {
            let interest = balance * rate
            let newBalance = balance + interest
            payment = min(newBalance, repayment)
            balance = newBalance - payment
            balance = balance >= 5 ? balance.round(to: 2) : 0

            table.append(.init(id: index, interest: interest, repayment: payment, balance: balance))
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

struct FixedPeriodRepayment {
    let duration: Int
    let fixedRate: Double
    let variableRate: Double

    var totalDuration: Int { duration * 12 }
}

enum Repayment: Equatable, CustomStringConvertible {
    case standard(Double)
    case fixedPeriod(FixedPeriodRepayment)

    var isValid: Bool {
        switch self {
        case .standard(let rate):
            return rate > 0
        case .fixedPeriod(let repayment):
            return repayment.duration > 0 &&
                repayment.fixedRate > 0 &&
                repayment.variableRate > 0
        }
    }

    var fixedPeriod: Int? {
        switch self {
        case .standard:
            return nil
        case .fixedPeriod(let term):
            return term.totalDuration
        }
    }

    static func == (lhs: Repayment, rhs: Repayment) -> Bool {
        switch (lhs, rhs) {
        case (.standard(let l), .standard(let r)):
            return l == r

        case (.fixedPeriod(let l), .fixedPeriod(let r)):
            return l.duration == r.duration && l.fixedRate == r.fixedRate && l.variableRate == r.variableRate

        default:
            return false
        }
    }

    var description: String {
        switch self {
        case .standard(let rate):
            return "Standard @ \(rate)%"
        case .fixedPeriod(let repayment):
            return "Fixed for \(repayment.duration) years @ \(repayment.fixedRate)% then @ \(repayment.variableRate)%"
        }
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

extension Int {
    var doubleValue: Double { Double(self) }
}
