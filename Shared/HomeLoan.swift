//: A UIKit based Playground for presenting user interface

import SwiftUI

class HomeLoan {
    let loanAmount: Double
    let term: Term

    var repayments: [Double] = []
    var table: [TableRow] = [] {
        didSet {
            totalInterest = table.map { $0.interest }.reduce(0, +)
            repayments = table.map { $0.repayment }
        }
    }

    var extraTable: [TableRow] = []

    var totalInterest: Double = 0

    var repaymentType: Repayment = .fixed(0)

    init(loanAmount: Double, term: Term) {
        self.loanAmount = loanAmount
        self.term = term

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
        switch term {
        case .fixed(let term):
            let rate = term.rate / 12 / 100
            let duration = self.term.totalDuration
            let over = loanAmount * rate * duration.doubleValue
            let under = 1 - Double(truncating: NSDecimalNumber(value: pow(1 + rate, -duration.doubleValue)))
            let totalLoan = over / under
            let repayment = totalLoan / duration.doubleValue

            repaymentType = .fixed(repayment)
            table = [TableRow(id: 0, interest: 0, repayment: 0, balance: loanAmount)] + createLoanTable(for: loanAmount, rate: rate, term: duration, repayment: repayment)
            extraTable = [TableRow(id: 0, interest: 0, repayment: 0, balance: loanAmount)] + createLoanTable(for: loanAmount, rate: rate, term: duration, repayment: 3000)

        case .mix(let term):
            let fixedRate = term.fixedRate / 12 / 100
            let duration = self.term.totalDuration
            let fixedOver = loanAmount * fixedRate * duration.doubleValue
            let fixedUnder = 1 - Double(truncating: NSDecimalNumber(value: pow(1 + fixedRate, -duration.doubleValue)))
            let fixedTotal = fixedOver / fixedUnder
            let fixedMonthly = (fixedTotal / duration.doubleValue).round(to: 2)

            let remainingTerm = duration.doubleValue - Double(term.fixedDuration)

            let fixedTable = Array(createLoanTable(for: loanAmount, rate: fixedRate, term: duration, repayment: fixedMonthly).prefix(term.fixedDuration))
            let balance = fixedTable.last?.balance ?? 0

            let variableRate = term.variableRate / 12 / 100
            let variableOver = balance * variableRate * remainingTerm
            let variableUnder = 1 - Double(truncating: NSDecimalNumber(value: pow(1 + variableRate, -remainingTerm)))
            let variableTotal = variableOver / variableUnder

            let remaining = variableTotal
            let variableMonthly = (remaining / remainingTerm).round(to: 2)

            let variableTable = createLoanTable(for: balance, rate: variableRate, term: Int(remainingTerm), repayment: variableMonthly, startIndex: term.fixedDuration)

            repaymentType = .mix(fixedMonthly, variableMonthly)
            table = [TableRow(id: 0, interest: 0, repayment: 0, balance: loanAmount)] + fixedTable + variableTable
        }
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

enum Term: CustomStringConvertible {
    case fixed(FixedTerm)
    case mix(MixedTerm)

    var totalDuration: Int {
        switch self {
        case .fixed(let val):
            return val.duration * 12
        case .mix(let val):
            return val.totalDuration * 12
        }
    }

    func monthlyInterestRate(for month: Int) -> Double {
        switch self {
        case .fixed(let term):
            return term.rate / 12 /  100
        case .mix(let term):
            if month <= term.fixedDuration {
                return term.fixedRate  / 12 /  100
            }

            return term.variableRate / 12 /  100
        }
    }

    var description: String {
        switch self {
        case .fixed(let term):
            return "at \(term.rate) for \(term.duration) years"
        case .mix(let term):
            return """
            at \(term.fixedRate) for \(term.fixedDuration) years
            then at \(term.variableRate) for \(term.totalDuration - term.fixedDuration) years
            """
        }
    }
}

struct FixedTerm {
    let duration: Int
    let rate: Double
}

struct MixedTerm {
    let totalDuration: Int
    let fixedDuration: Int
    let fixedRate: Double
    let variableRate: Double
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

enum Repayment: CustomStringConvertible {
    case fixed(Double)
    case mix(Double, Double)

    var description: String {
        switch self {
        case .fixed(let val):
            return val.currencyString + "/ month"
        case .mix(let fixed, let after):
            return fixed.currencyString + " during fixed period\n" + after.currencyString + " after fixed period"
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
