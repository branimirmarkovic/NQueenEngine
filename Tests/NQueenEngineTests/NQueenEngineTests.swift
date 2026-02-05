import Testing
@testable import NQueenEngine

@MainActor
struct EngineTests: Sendable {
    
    @Test(arguments: [
        (givenSize: 4, expectedBoardSize: 4),
        (givenSize: 5, expectedBoardSize: 5),
        (givenSize: 8, expectedBoardSize: 8)
    ]) func init_givenSize_createdCorrectBoardSize(
        givenSize: Int,
        expectedBoardSize: Int
    ) async {
        let sut = makeSUT(size: givenSize)
        
        #expect(await sut.board.size == expectedBoardSize)
    }
    
    @Test func init_givenNoAlreadyPlacedQueens_queenArraysCreatedEmpty() async {
        let sut = makeSUT(size: 4)
        
        #expect(await sut.board.queens.isEmpty)
    }
    
    @Test func init_giveAlreadyPlacedQueens_queenArraysCreatedWithGivenQueens() async {
        let sut = makeSUT(size: 4, queens: [Position(row: 0, column: 0), Position(row: 1, column: 2)])
        let expectedQueens = Set([Position(row: 0, column: 0), Position(row: 1, column: 2)])
        
        #expect(await sut.board.queens == expectedQueens)
    }
    
    @Test(arguments: [
        (
            size: 4,
            placedQueens: Set([Position(row: 0, column: 0)]),expectedCount: 3
        ),
        (
            size: 4,
            placedQueens: Set([Position(row: 0, column: 0), Position(row: 1, column: 2)]),
            expectedCount: 2
        ),
        (
            size: 5,
            placedQueens: Set([Position(row: 0, column: 0), Position(row: 1, column: 2), Position(row: 2, column: 4)]),
            expectedCount: 2
        ),
        (
            size: 2,
            placedQueens: Set([Position(row: 0, column: 0), Position(row: 1, column: 2), Position(row: 2, column: 4), Position(row: 3, column: 1)]),
            expectedCount: 0
        )
    ]) func remainingQueensCount_givenBoardSize_andPlacesQueens_returnsCorrectValue(
        size: Int,
        placedQueens: Set<Position>,
        expectedCount: Int
    ) async {
        let sut = makeSUT(size: size, queens: placedQueens)
        
        #expect(await sut.remainingQueens == expectedCount)
    }
    
    @Test(arguments: [
        (
            positionToCheck: Position(row: 0, column: 0),
            placedQueenPositions: Set([Position(row: 0, column: 0)]),
            expectedValue: true
        ),
        (
            positionToCheck: Position(row: 1, column: 2),
            placedQueenPositions: Set([Position(row: 0, column: 0), Position(row: 1, column: 2)]),
            expectedValue: true
        ),
        (
            positionToCheck: Position(row: 2, column: 3),
            placedQueenPositions: Set([Position(row: 0, column: 0), Position(row: 1, column: 2), Position(row: 2, column: 4)]),
            expectedValue: false
        )
    ]) func isOccupied_givenPositions_andPlacedQueenPositions_returnsCorrectValue(positionToCheck: Position, placedQueenPositions: Set<Position>, expectedValue: Bool) async {
        let sut = makeSUT(size: 10, queens: placedQueenPositions)
        #expect(await sut.isOccupied(positionToCheck) == expectedValue)
    }
        
        
    
    typealias SUT = NQueensEngine
    private func makeSUT(size: Int = 3, queens: Set<Position> = []) -> SUT {
        NQueensEngine(size:size, queens: queens)
    }
    
}
