//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import LoanCalculator

private struct HomeLoan {
    let houseCost: Double
    let term: Term
    let interestRate: Double
    let deposit: Double

    var loanAmount: Double {
        houseCost - deposit
    }

    var monthlyInterestRate: Double {
        interestRate / 12 /  100
    }

    func totalLoan() -> Double {
        let over = loanAmount * monthlyInterestRate * term.doubleValue
        let under = 1 - Double(truncating: NSDecimalNumber(value: pow(1 + monthlyInterestRate, -term.doubleValue)))
        return (over / under).roundUp(to: 2)
    }

    var monthlyRepayment: Double {
        (totalLoan() / term.doubleValue).roundUp(to: 2)
    }

    func createLoanTable() {
        let amount = loanAmount
        let rate = monthlyInterestRate
        var balance = amount
        var repayment = monthlyRepayment

        var index = 1

        print("#  | Payment | Interest | Balance")
        print("0 | \(0) | \(0) | \(balance.roundUp(to: 2))")

        while balance > 5 {
            let interest = (balance * rate).roundUp(to: 2)
            let newBalance = (balance - repayment + interest).roundUp(to: 2)
            balance = newBalance >= 5 ? newBalance : 0
            repayment = min(repayment, balance)
            print("\(index) | \(repayment) | \(interest) | \(balance.roundUp(to: 2))")

            if index.isMultiple(of: 12) {
                print("----", balance, "----")
            }
            index += 1
        }
    }
}

private enum Term {
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
}

class MyViewController : UIViewController {

    override func viewDidLoad() {
        var loan = HomeLoan(houseCost: 750000, term: .years(30), interestRate: 1.99, deposit: 120000)
//        print(loan.loanAmount)
//        print(loan.term.value)
//        print(loan.monthlyInterestRate)
        print(loan.totalLoan())
        print(loan.monthlyRepayment)
        loan.createLoanTable()
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

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
