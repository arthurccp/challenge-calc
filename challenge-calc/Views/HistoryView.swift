import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: CalculatorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var confirmsClear = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.history.isEmpty {
                    ContentUnavailableView("Nenhum cálculo", systemImage: "clock",
                                           description: Text("Seus cálculos concluídos aparecerão aqui."))
                } else {
                    List {
                        ForEach(viewModel.history) { calculation in
                            Button {
                                viewModel.reuse(calculation)
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(calculation.expression)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Text("= \(viewModel.formatted(calculation.result))")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    Text(calculation.date, format: .dateTime.day().month().year().hour().minute())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint("Toque para reutilizar o resultado")
                            .swipeActions {
                                Button("Excluir", role: .destructive) {
                                    viewModel.delete(calculation)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Histórico")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Limpar", role: .destructive) { confirmsClear = true }
                        .disabled(viewModel.history.isEmpty)
                }
            }
            .confirmationDialog("Excluir todo o histórico?", isPresented: $confirmsClear,
                                titleVisibility: .visible) {
                Button("Excluir tudo", role: .destructive) { viewModel.clearHistory() }
                Button("Cancelar", role: .cancel) {}
            }
            .alert("Atenção", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}
