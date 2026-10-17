import SwiftUI

struct CalculatorView: View {
    @StateObject private var viewModel = CalculatorViewModel()
    @State private var showsHistory = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 16) {
                        Spacer(minLength: 16)
                        VStack(alignment: .trailing, spacing: 12) {
                            Text(viewModel.expression.isEmpty ? " " : viewModel.expression)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                            Text(viewModel.display)
                                .font(.system(size: 56, weight: .medium, design: .rounded))
                                .minimumScaleFactor(0.25)
                                .accessibilityLabel("Resultado: \(viewModel.display)")
                        }
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.vertical, 24)
                        keypad
                    }
                    .padding(20)
                    .frame(minHeight: geometry.size.height, alignment: .bottom)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Calculadora")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Histórico", systemImage: "clock.arrow.circlepath") {
                        showsHistory = true
                    }
                }
            }
            .sheet(isPresented: $showsHistory) {
                HistoryView(viewModel: viewModel)
            }
            .alert("Atenção", isPresented: Binding(
                get: { !showsHistory && viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .tint(.orange)
    }

    private var keypad: some View {
        Grid(horizontalSpacing: 12, verticalSpacing: 12) {
            GridRow {
                key("AC", accessibilityLabel: "Limpar cálculo", action: viewModel.clear)
                    .gridCellColumns(3)
                operationKey(.divide)
            }
            ForEach(0..<3) { row in
                GridRow {
                    ForEach(0..<3) { column in
                        let digit = (3 - row) * 3 - 2 + column
                        key(String(digit)) { viewModel.enterDigit(digit) }
                    }
                    operationKey([.multiply, .subtract, .add][row])
                }
            }
            GridRow {
                key("0") { viewModel.enterDigit(0) }
                    .gridCellColumns(2)
                key(viewModel.decimalButtonTitle, accessibilityLabel: "Separador decimal",
                    action: viewModel.enterDecimalSeparator)
                key("=", accessibilityLabel: "Igual", prominent: true, action: viewModel.calculate)
            }
        }
    }

    private func operationKey(_ operation: ArithmeticOperation) -> some View {
        key(operation.rawValue, accessibilityLabel: operationLabel(operation), prominent: true) {
            viewModel.selectOperation(operation)
        }
    }

    private func operationLabel(_ operation: ArithmeticOperation) -> String {
        switch operation {
        case .add: return "Somar"
        case .subtract: return "Subtrair"
        case .multiply: return "Multiplicar"
        case .divide: return "Dividir"
        }
    }

    private func key(_ title: String, accessibilityLabel: String? = nil,
                     prominent: Bool = false, height: CGFloat = 60,
                     action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.title2.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .foregroundStyle(prominent ? Color.black : Color.primary)
                .background(prominent ? Color.orange : Color(.secondarySystemGroupedBackground),
                            in: RoundedRectangle(cornerRadius: 16))
                .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel ?? title)
    }
}
