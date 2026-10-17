import Foundation
import Combine

final class CalculatorViewModel: ObservableObject {
    @Published private(set) var display = "0"
    @Published private(set) var expression = ""
    @Published private(set) var history: [Calculation] = []
    @Published var errorMessage: String?

    private let store: CalculationHistoryStore
    private var accumulator: Decimal?
    private var pendingOperation: ArithmeticOperation?
    private var startsNewEntry = true
    private var hasEnteredOperand = false
    private var historyIsAvailable = true
    private let decimalSeparator = Locale.current.decimalSeparator ?? ","

    init(store: CalculationHistoryStore = CalculationHistoryStore()) {
        self.store = store
        do {
            history = try store.load()
        } catch {
            historyIsAvailable = false
            errorMessage = "Não foi possível carregar o histórico. Os dados armazenados foram preservados."
        }
    }

    var decimalButtonTitle: String { decimalSeparator }

    func enterDigit(_ digit: Int) {
        guard (0...9).contains(digit) else { return }
        prepareEntry()
        guard display.filter({ $0.isNumber }).count < 16 else { return }
        display = display == "0" ? String(digit) : display + String(digit)
        hasEnteredOperand = true
    }

    func enterDecimalSeparator() {
        prepareEntry()
        guard !display.contains(decimalSeparator) else { return }
        display += decimalSeparator
        hasEnteredOperand = true
    }

    func selectOperation(_ operation: ArithmeticOperation) {
        guard let value = enteredValue else { return }
        do {
            if let pendingOperation, let accumulator, hasEnteredOperand {
                let result = try pendingOperation.calculate(accumulator, value)
                self.accumulator = result
                display = formatted(result)
            } else if pendingOperation == nil {
                accumulator = value
            }
            pendingOperation = operation
            expression = "\(display) \(operation.rawValue)"
            startsNewEntry = true
            hasEnteredOperand = false
        } catch {
            handleCalculationError(error)
        }
    }

    func calculate() {
        guard let operation = pendingOperation, let accumulator,
              hasEnteredOperand, let operand = enteredValue else { return }
        do {
            let result = try operation.calculate(accumulator, operand)
            let completedExpression = "\(formatted(accumulator)) \(operation.rawValue) \(display)"
            display = formatted(result)
            expression = completedExpression + " ="
            self.accumulator = nil
            pendingOperation = nil
            startsNewEntry = true
            hasEnteredOperand = false
            saveCalculation(Calculation(expression: completedExpression, result: result))
        } catch {
            handleCalculationError(error)
        }
    }

    func clear() {
        display = "0"
        expression = ""
        accumulator = nil
        pendingOperation = nil
        startsNewEntry = true
        hasEnteredOperand = false
    }

    func reuse(_ calculation: Calculation) {
        clear()
        display = formatted(calculation.result)
    }

    func delete(_ calculation: Calculation) {
        persist(history.filter { $0.id != calculation.id })
    }

    func clearHistory() {
        persist([])
    }

    func formatted(_ value: Decimal) -> String {
        NSDecimalNumber(decimal: value).stringValue
            .replacingOccurrences(of: ".", with: decimalSeparator)
    }

    private var enteredValue: Decimal? {
        Decimal(string: display.replacingOccurrences(of: decimalSeparator, with: "."),
                locale: Locale(identifier: "en_US_POSIX"))
    }

    private func prepareEntry() {
        guard startsNewEntry else { return }
        display = "0"
        startsNewEntry = false
        if pendingOperation == nil { expression = "" }
    }

    private func saveCalculation(_ calculation: Calculation) {
        persist([calculation] + history)
    }

    private func persist(_ updatedHistory: [Calculation]) {
        guard historyIsAvailable else {
            errorMessage = "O histórico está indisponível. Reabra o aplicativo para tentar carregá-lo novamente."
            return
        }
        do {
            try store.save(updatedHistory)
            history = updatedHistory
        } catch {
            errorMessage = "Não foi possível salvar a alteração no histórico. Tente novamente."
        }
    }

    private func handleCalculationError(_ error: Error) {
        clear()
        errorMessage = error.localizedDescription
    }
}
