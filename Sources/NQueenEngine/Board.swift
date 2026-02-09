//
//  Board.swift
//  NQueenEngine
//
//  Created by Branimir Markovic on 5. 2. 2026..
//
import Foundation

public struct Board: Equatable, Sendable {
    public let size: Int
    public var queens: Set<Position>

    public init(size: Int, queens: Set<Position> = []) {
        self.size = size
        self.queens = queens
    }
}

public struct Position: Hashable, Sendable {
    public let row: Int
    public let column: Int

    public init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
}

public enum PlacementError: Error, Equatable, Sendable {
    case invalidPosition
    case positionOccupied
    case conflicts
    case noQueensRemaining
}
