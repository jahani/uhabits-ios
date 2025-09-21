import Foundation

enum HabitScoreCalculator {
    static func compute(frequency: Double, previousScore: Double, checkmarkValue: Double) -> Double {
        guard frequency.isFinite, frequency > 0 else {
            return previousScore
        }
        let clamped = max(0.0, min(1.0, checkmarkValue))
        let multiplier = pow(0.5, sqrt(frequency) / 13.0)
        let score = previousScore * multiplier + clamped * (1.0 - multiplier)
        return max(0.0, min(1.0, score))
    }
}
