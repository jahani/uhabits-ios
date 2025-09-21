import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct ScoreChartView: View {
    var samples: [ScoreSample]

    var body: some View {
        #if canImport(Charts)
        if #available(iOS 16.0, *) {
            Chart(samples.suffix(120)) { sample in
                LineMark(
                    x: .value("Date", sample.date),
                    y: .value("Score", sample.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(LinearGradient(
                    colors: [.blue, .green],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                AreaMark(
                    x: .value("Date", sample.date),
                    y: .value("Score", sample.value)
                )
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.25), Color.clear]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks(values: stride(from: 0.0, through: 1.0, by: 0.25)) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text("\(Int(doubleValue * 100))%")
                        }
                    }
                }
            }
        } else {
            placeholder
        }
        #else
        placeholder
        #endif
    }

    private var placeholder: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "waveform")
                .font(.title)
                .foregroundColor(.secondary)
            Text("Charts are not available in this preview.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ScoreChartView(samples: PreviewData.bootstrapHabits.first!.scoreTimeline())
        .frame(height: 220)
        .padding()
}
