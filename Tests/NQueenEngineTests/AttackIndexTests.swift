import Testing
@testable import NQueenEngine

@MainActor
struct AttackIndexTests: Sendable {
    
    @Test func wouldConflict_withEmptyIndex_returnsFalse() async throws {
        let sut = makeSUT()
        
        #expect(sut.wouldConflict(Position(row: 0, column: 0)) == false)
    }
    
    @Test(arguments: [
        (Position(row: 1, column: 3), true), // same row
        (Position(row: 3, column: 1), true), // same column
        (Position(row: 2, column: 2), true), // main diagonal
        (Position(row: 0, column: 2), true), // anti-diagonal
        (Position(row: 0, column: 3), false) // safe
    ]) func wouldConflict_withQueen_givenDifferentPositions_returnsExpectedValue(position: Position, expectedValue: Bool) async throws {
        let queen = Position(row: 1, column: 1)
        let sut = makeSUT(queens: [queen])
        
        #expect(sut.wouldConflict(position) == expectedValue)
    }
    
    @Test func insert_givenPosition_indexesHaveCorrectValue() async throws {
        var sut = makeSUT()
        let queen = Position(row: 2, column: 0)
        
        sut.insert(queen)
        
        #expect(sut.occupiedColumns.contains(0) == true)
        #expect(sut.occupiedRows.contains(2) == true)
        #expect(sut.occupiedDiagonalsDown.contains(2) == true)
        #expect(sut.occupiedDiagonalsUp.contains(2) == true)
    }
    
    @Test func remove_givenPosition_indexesHaveCorrectValue() async throws {
        let queen = Position(row: 2, column: 0)
        var sut = makeSUT(queens: [queen])
        
        sut.remove(queen)
        
        #expect(sut.occupiedColumns.contains(0) == false)
        #expect(sut.occupiedRows.contains(2) == false)
        #expect(sut.occupiedDiagonalsDown.contains(2) == false)
        #expect(sut.occupiedDiagonalsUp.contains(2) == false)
    }
    
    private func makeSUT(size: Int = 4, queens: Set<Position> = []) -> AttackIndex {
        AttackIndex(size: size, queens: queens)
    }
}
