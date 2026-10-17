import Foundation

struct Calculation: Codable, Identifiable {
    let id: UUID
    let expression: String
    let result: Decimal
    let date: Date

    init(expression: String, result: Decimal) {
        id = UUID()
        self.expression = expression
        self.result = result
        date = Date()
    }
}

enum ArithmeticOperation: String, CaseIterable {
    case add = "+"
    case subtract = "−"
    case multiply = "×"
    case divide = "÷"

    func calculate(_ lhs: Decimal, _ rhs: Decimal) throws -> Decimal {
        guard self != .divide || rhs != 0 else {
            throw CalculationError.divisionByZero
        }
        var left = lhs
        var right = rhs
        var result = Decimal()
        let status: Decimal.CalculationError
        switch self {
        case .add: status = NSDecimalAdd(&result, &left, &right, .plain)
        case .subtract: status = NSDecimalSubtract(&result, &left, &right, .plain)
        case .multiply: status = NSDecimalMultiply(&result, &left, &right, .plain)
        case .divide: status = NSDecimalDivide(&result, &left, &right, .plain)
        }
        guard !result.isNaN, status == .noError || status == .lossOfPrecision else {
            throw CalculationError.outOfRange
        }
        return result
    }
}

enum CalculationError: LocalizedError {
    case divisionByZero
    case outOfRange

    var errorDescription: String? {
        switch self {
        case .divisionByZero: return "Não é possível dividir por zero."
        case .outOfRange: return "O número excede o limite da calculadora."
        }
    }
}
