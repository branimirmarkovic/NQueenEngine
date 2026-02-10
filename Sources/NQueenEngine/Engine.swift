//
//  File.swift
//  NQueenEngine
//
//  Created by Branimir Markovic on 5. 2. 2026..
//

import Foundation

public enum EngineError: Error, Equatable {
    case invalidBoardSize
}

public final class NQueensEngine {
    public private(set) var board: Board

    private var index: AttackIndex

    public init(size: Int, queens: Set<Position> = []) throws {
        guard size >= 3 else { throw EngineError.invalidBoardSize }
        self.board = Board(size: size, queens: queens)
        self.index = AttackIndex(size: size, queens: queens)
    }

    public var remainingQueensCount: Int {
        max(0, board.size - board.queens.count)
    }

    public func isOccupied(_ position: Position) -> Bool {
        board.queens.contains(position)
    }

    public func toggle(_ position: Position, checkConflict: Bool = true) throws {
        if board.queens.contains(position) {
            try remove(position)
        } else {
            try place(position, checkConflict: checkConflict)
        }
    }

    public func place(_ position: Position, checkConflict: Bool = true) throws {
        try validate(position)

        guard remainingQueensCount > 0 else { throw PlacementError.noQueensRemaining }
        guard board.queens.contains(position) == false else { throw PlacementError.positionOccupied }
        if checkConflict {
            guard index.wouldConflict(position) == false else { throw PlacementError.conflicts }
        }
        

        board.queens.insert(position)
        index.insert(position)
    }

    public func remove(_ position: Position) throws {
        try validate(position)
        guard board.queens.remove(position) != nil else { return }

        index.remove(position)
    }
    
    public func availablePositions() -> [Position] {
        var result: [Position] = []
        for row in 0..<board.size {
            for column in 0..<board.size {
                let pos = Position(row: row, column: column)
                if !isOccupied(pos) && !index.wouldConflict(pos) {
                    result.append(pos)
                }
            }
        }
        return result
    }
    
    public func conflictingPositions() -> [Position] {
        var rowCounts: [Int: Int] = [:]
        var columnCounts: [Int: Int] = [:]
        var diagonalDownCounts: [Int: Int] = [:]
        var diagonalUpCounts: [Int: Int] = [:]

        for queen in board.queens {
            rowCounts[queen.row, default: 0] += 1
            columnCounts[queen.column, default: 0] += 1
            diagonalDownCounts[queen.row - queen.column, default: 0] += 1
            diagonalUpCounts[queen.row + queen.column, default: 0] += 1
        }

        let conflicts = board.queens.filter { queen in
            (rowCounts[queen.row] ?? 0) > 1 ||
            (columnCounts[queen.column] ?? 0) > 1 ||
            (diagonalDownCounts[queen.row - queen.column] ?? 0) > 1 ||
            (diagonalUpCounts[queen.row + queen.column] ?? 0) > 1
        }

        return conflicts.sorted { lhs, rhs in
            lhs.row == rhs.row ? lhs.column < rhs.column : lhs.row < rhs.row
        }
    }

    func validate(_ p: Position) throws {
        guard isValid(p) else { throw PlacementError.invalidPosition }
    }

    func isValid(_ p: Position) -> Bool {
        p.row >= 0 && p.column >= 0 && p.row < board.size && p.column < board.size
    }
}

private struct AttackIndex {
    private var occupiedColumns: Set<Int>
    private var occupiedRows: Set<Int>
    private var occupiedDiagonalsDown: Set<Int>
    private var occupiedDiagonalsUp: Set<Int>

    init(size: Int, queens: Set<Position>) {
        self.occupiedColumns = []
        self.occupiedRows = []
        self.occupiedDiagonalsDown = []
        self.occupiedDiagonalsUp = []

        for q in queens {
            insert(q)
        }
    }

    func wouldConflict(_ p: Position) -> Bool {
        occupiedColumns.contains(p.column) ||
        occupiedRows.contains(p.row) ||
        occupiedDiagonalsDown.contains(p.row - p.column) ||
        occupiedDiagonalsUp.contains(p.row + p.column)
    }

    mutating func insert(_ p: Position) {
        occupiedColumns.insert(p.column)
        occupiedRows.insert(p.row)
        occupiedDiagonalsDown.insert(p.row - p.column)
        occupiedDiagonalsUp.insert(p.row + p.column)
    }

    mutating func remove(_ p: Position) {
        occupiedColumns.remove(p.column)
        occupiedRows.remove(p.row)
        occupiedDiagonalsDown.remove(p.row - p.column)
        occupiedDiagonalsUp.remove(p.row + p.column)
    }
}
