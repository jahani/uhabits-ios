import XCTest
@testable import LoopHabitTracker

final class HabitScoreCalculatorTests: XCTestCase {
    func testScoreDecay() {
        let frequency = 1.0
        var score = 1.0
        score = HabitScoreCalculator.compute(frequency: frequency, previousScore: score, checkmarkValue: 0)
        let dayWithoutCompletion = HabitScoreCalculator.compute(frequency: frequency, previousScore: score, checkmarkValue: 0)
        XCTAssertLessThan(dayWithoutCompletion, score)
    }

    func testScoreIncrease() {
        var score = 0.0
        for _ in 0..<7 {
            score = HabitScoreCalculator.compute(frequency: 1.0, previousScore: score, checkmarkValue: 1)
        }
        XCTAssertGreaterThan(score, 0.9)
    }
}
