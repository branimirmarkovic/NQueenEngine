//
//  AttackIndex.swift
//  NQueenEngine
//
//  Created by Branimir Markovic on 10. 2. 2026..
//


struct AttackIndex {
    private(set) var occupiedColumns: Set<Int>
    private(set) var occupiedRows: Set<Int>
    private(set) var occupiedDiagonalsDown: Set<Int>
    private(set) var occupiedDiagonalsUp: Set<Int>
    
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
