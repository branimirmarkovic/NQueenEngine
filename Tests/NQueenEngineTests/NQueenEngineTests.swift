import Testing
@testable import NQueenEngine

@MainActor
struct EngineTests: Sendable {
    
    @Test(arguments: [
        (givenSize: 4, expectedBoardSize: 4),
        (givenSize: 5, expectedBoardSize: 5),
        (givenSize: 8, expectedBoardSize: 8)
    ]) func init_givenSize_createdCorrectBoardSize(givenSize: Int, expectedBoardSize: Int) async {
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
        
    
    typealias SUT = NQueensEngine
    private func makeSUT(size: Int = 3, queens: Set<Position> = []) -> SUT {
        NQueensEngine(size:size, queens: queens)
    }
    
}
