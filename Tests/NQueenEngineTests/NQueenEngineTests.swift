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
    ) async throws {
        let sut = try makeSUT(size: givenSize)
        
        #expect(sut.board.size == expectedBoardSize)
    }
    
    @Test func init_givenNoAlreadyPlacedQueens_queenArraysCreatedEmpty() async throws {
        let sut = try makeSUT(size: 4)
        
        #expect(sut.board.queens.isEmpty)
    }
    
    @Test func init_giveAlreadyPlacedQueens_queenArraysCreatedWithGivenQueens() async throws {
        let sut = try makeSUT(size: 4, queens: [Position(row: 0, column: 0), Position(row: 1, column: 2)])
        let expectedQueens = Set([Position(row: 0, column: 0), Position(row: 1, column: 2)])
        
        #expect(sut.board.queens == expectedQueens)
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
        )
    ]) func remainingQueensCount_givenBoardSize_andPlacesQueens_returnsCorrectValue(
        size: Int,
        placedQueens: Set<Position>,
        expectedCount: Int
    ) async throws {
        let sut = try makeSUT(size: size, queens: placedQueens)
        
        #expect(sut.remainingQueensCount == expectedCount)
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
    ]) func isOccupied_givenPositions_andPlacedQueenPositions_returnsCorrectValue(positionToCheck: Position, placedQueenPositions: Set<Position>, expectedValue: Bool) async throws {
        let sut = try makeSUT(size: 10, queens: placedQueenPositions)
        #expect(sut.isOccupied(positionToCheck) == expectedValue)
    }

    @Test func place_validPosition_insertsQueen() async throws {
        let sut = try makeSUT(size: 4)
        let position = Position(row: 1, column: 3)

        try sut.place(position)

        #expect(sut.board.queens == Set([position]))
        #expect(sut.remainingQueensCount == 3)
    }

    @Test func place_invalidPosition_throwsInvalidPosition() async throws {
        let sut = try makeSUT(size: 4)
        let position = Position(row: -1, column: 0)

        #expect(throws: PlacementError.invalidPosition) {
            try sut.place(position)
        }
    }

    @Test func place_conflictingPosition_throwsConflicts() async throws {
        let sut = try makeSUT(size: 4, queens: [Position(row: 0, column: 0)])
        let position = Position(row: 1, column: 1)

        #expect(throws: PlacementError.conflicts) {
            try sut.place(position)
        }
    }

    @Test func place_noQueensRemaining_throwsNoQueensRemaining() async throws {
        let sut = try makeSUT(size: 3, queens: [Position(row: 0, column: 0), Position(row: 1, column: 2), Position(row: 2, column: 1)])
        let position = Position(row: 0, column: 1)
        #expect(throws: PlacementError.noQueensRemaining) {
            try sut.place(position)
        }
    }

    @Test func remove_existingPosition_removesQueen() async throws {
        let position = Position(row: 0, column: 0)
        let sut = try makeSUT(size: 4, queens: [position])

        try  sut.remove(position)

        #expect(sut.board.queens.isEmpty)
    }

    @Test func remove_invalidPosition_noChange() async throws {
        let existing = Position(row: 0, column: 0)
        let sut = try makeSUT(size: 4, queens: [existing])

        #expect(throws: PlacementError.invalidPosition) {
            try sut.remove(Position(row: 10, column: 10))
        }
    }

    @Test func toggle_unoccupiedPosition_placesQueen() async throws {
        let sut = try makeSUT(size: 4)
        let position = Position(row: 0, column: 1)

        try sut.toggle(position)

        #expect(sut.board.queens == Set([position]))
    }

    @Test func toggle_occupiedPosition_removesQueen() async throws {
        let position = Position(row: 0, column: 1)
        let sut = try makeSUT(size: 4, queens: [position])

        try sut.toggle(position)

        #expect(sut.board.queens.isEmpty)
    }

    @Test func toggle_invalidPosition_throwsInvalidPosition() async throws {
        let sut = try makeSUT(size: 4)

        #expect(throws: PlacementError.invalidPosition) {
            try sut.toggle(Position(row: 99, column: 0))
        }
    }
        
    @Test func place_onOccupiedPosition_throwsOccupied() async throws {
        let position = Position(row: 2, column: 2)
        let conflictingPosition = Position(row: 3, column: 3)
        let sut = try makeSUT(size: 4, queens: [position])

        #expect(throws: PlacementError.conflicts) {
            try sut.place(conflictingPosition)
        }
    }

    @Test func place_onBoardEdge_placesQueen() async throws {
        let position = Position(row: 0, column: 3)
        let sut = try makeSUT(size: 4)

        try sut.place(position)

        #expect(sut.board.queens == Set([position]))
    }

    @Test func remove_fromEmptyBoard_noChange() async throws {
        let sut = try makeSUT(size: 4)
        try sut.remove(Position(row: 1, column: 1))
        #expect(sut.board.queens.isEmpty)
    }


    @Test func place_allQueensPlaced_throwsNoQueensRemaining() async throws {
        let positions = Set([
            Position(row: 0, column: 0),
            Position(row: 1, column: 1),
            Position(row: 2, column: 2),
            Position(row: 3, column: 3)
        ])
        let sut = try makeSUT(size: 4, queens: positions)
        #expect(throws: PlacementError.noQueensRemaining) {
            try sut.place(Position(row: 0, column: 1))
        }
    }

    @Test func init_givenInvalidBoardSize_throwsInvalidBoardSize()  {
        #expect(throws: EngineError.invalidBoardSize) {
            _ = try makeSUT(size: 2)
        }
    }
    
    @Test func availablePositions_onEmptyBoard_returnsAllPositions() async throws {
        let size = 4
        let expected = Set((0..<size).flatMap { row in (0..<size).map { column in Position(row: row, column: column) } })
        
        let sut = try makeSUT(size: size)
        
        let result = Set(sut.availablePositions())
        #expect(result == expected)
    }
    
    @Test func availablePositions_withPlacedQueen_blocksAttackedPositions() async throws {
        let size = 4
        let queen = Position(row: 1, column: 1)
        let unavailable = Set([
            Position(row: 1, column: 0), Position(row: 1, column: 1), Position(row: 1, column: 2), Position(row: 1, column: 3),
            Position(row: 0, column: 1), Position(row: 1, column: 1), Position(row: 2, column: 1), Position(row: 3, column: 1),
            Position(row: 0, column: 0), Position(row: 0, column: 2), Position(row: 2, column: 0), Position(row: 2, column: 2),
            Position(row: 3, column: 3), Position(row: 3, column: 1)
        ])
        
        let expected = Set((0..<size).flatMap { row in (0..<size).map { column in Position(row: row, column: column) } })
            .subtracting(unavailable)
        
        let sut = try makeSUT(size: size, queens: [queen])
        
        let result = Set(sut.availablePositions())
        #expect(result == expected)
    }
    
    @Test func availablePositions_whenNoAvailablePositions_returnsEmpty() async throws {
        let size = 3
        let queens: Set<Position> = [Position(row: 0, column: 0), Position(row: 1, column: 1), Position(row: 2, column: 2)]
        
        let sut = try makeSUT(size: size, queens: queens)
        
        let result = sut.availablePositions()
        #expect(result.isEmpty)
    }
    
    typealias SUT = NQueensEngine
    private func makeSUT(size: Int = 3, queens: Set<Position> = []) throws -> SUT {
        try NQueensEngine(size:size, queens: queens)
    }
    
}
