//
//  File.swift
//  NQueenEngine
//
//  Created by Branimir Markovic on 5. 2. 2026..
//

import Foundation

public actor NQueensEngine {
    public private(set) var board: Board

    private var index: AttackIndex

    public init(size: Int, queens: Set<Position> = []) {
        self.board = Board(size: size, queens: queens)
        self.index = AttackIndex(size: size, queens: queens)
    }

    public var remainingQueens: Int {
        max(0, board.size - board.queens.count)
    }

    public func isOccupied(_ p: Position) -> Bool {
        board.queens.contains(p)
    }

    public func toggle(_ p: Position) throws {
        try validate(p)

        if board.queens.contains(p) {
            remove(p)
        } else {
            try place(p)
        }
    }

    public func place(_ p: Position) throws {
        try validate(p)

        guard remainingQueens > 0 else { throw PlacementError.noQueensRemaining }
        guard board.queens.contains(p) == false else { throw PlacementError.positionOccupied }
        guard index.wouldConflict(p) == false else { throw PlacementError.conflicts }

        board.queens.insert(p)
        index.insert(p)
    }

    public func remove(_ p: Position) {
        guard isValid(p) else { return }
        guard board.queens.remove(p) != nil else { return }

        index.remove(p)
    }

    public func reset(size: Int? = nil) {
        let newSize = size ?? board.size
        board = Board(size: newSize)
        index = AttackIndex(size: newSize, queens: [])
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
