import Foundation

public struct ClearResult: Equatable {
    public let clearedRows: [Int]
    public let clearedCols: [Int]
    public let clearedCoordinates: Set<Coordinate>
    public let linesClearedCount: Int

    public var hasClears: Bool {
        linesClearedCount > 0
    }

    public init(clearedRows: [Int], clearedCols: [Int], clearedCoordinates: Set<Coordinate>) {
        self.clearedRows = clearedRows
        self.clearedCols = clearedCols
        self.clearedCoordinates = clearedCoordinates
        self.linesClearedCount = clearedRows.count + clearedCols.count
    }
}

public struct Board: Equatable {
    public static let size = 8
    
    /// 64-bit mask where each bit represents a cell: bit = (row * 8 + col)
    public private(set) var bitboard: UInt64 = 0
    
    /// Stores the color index for each occupied cell (nil = vacant)
    public private(set) var grid: [[Int?]] = Array(repeating: Array(repeating: nil, count: 8), count: 8)

    public init() {}

    /// Reset board to pristine state
    public mutating func reset() {
        bitboard = 0
        grid = Array(repeating: Array(repeating: nil, count: 8), count: 8)
    }

    /// Check if a cell is filled
    public func isOccupied(row: Int, col: Int) -> Bool {
        guard row >= 0 && row < 8 && col >= 0 && col < 8 else { return false }
        let bitIndex = row * 8 + col
        return (bitboard & (UInt64(1) << bitIndex)) != 0
    }

    /// Check if a piece can be legally placed at (originRow, originCol)
    public func canPlace(piece: Piece, atOriginRow originRow: Int, originCol: Int) -> Bool {
        guard let pieceMask = piece.bitmask(atOriginRow: originRow, originCol: originCol) else {
            return false
        }
        return (bitboard & pieceMask) == 0
    }

    /// Tests if the piece can be placed anywhere on the current board
    public func canPlaceAnywhere(piece: Piece) -> Bool {
        let maxRow = Self.size - piece.height
        let maxCol = Self.size - piece.width
        guard maxRow >= 0 && maxCol >= 0 else { return false }
        
        for r in 0...maxRow {
            for c in 0...maxCol {
                if canPlace(piece: piece, atOriginRow: r, originCol: c) {
                    return true
                }
            }
        }
        return false
    }

    /// Attempts to place the piece and clears any completed lines.
    /// Returns ClearResult if successful, or nil if placement was invalid.
    @discardableResult
    public mutating func place(piece: Piece, atOriginRow originRow: Int, originCol: Int) -> ClearResult? {
        guard canPlace(piece: piece, atOriginRow: originRow, originCol: originCol) else {
            return nil
        }
        guard let pieceMask = piece.bitmask(atOriginRow: originRow, originCol: originCol) else {
            return nil
        }

        // Apply piece to bitboard
        bitboard |= pieceMask

        // Update color grid
        for coord in piece.coordinates {
            let r = originRow + coord.row
            let c = originCol + coord.col
            grid[r][c] = piece.colorIndex
        }

        // Scan for completed rows and columns
        var completedRows: [Int] = []
        var completedCols: [Int] = []

        // Check rows: row mask is 0xFF shifted by (r * 8)
        for r in 0..<Self.size {
            let rowMask: UInt64 = 0xFF << (r * 8)
            if (bitboard & rowMask) == rowMask {
                completedRows.append(r)
            }
        }

        // Check columns: col mask has bit set at (r * 8 + c) for all r in 0..<8
        let singleColMask: UInt64 = 0x0101010101010101
        for c in 0..<Self.size {
            let colMask: UInt64 = singleColMask << c
            if (bitboard & colMask) == colMask {
                completedCols.append(c)
            }
        }

        // Gather all cleared coordinates
        var clearedCoords = Set<Coordinate>()
        for r in completedRows {
            for c in 0..<Self.size {
                clearedCoords.insert(Coordinate(row: r, col: c))
            }
        }
        for c in completedCols {
            for r in 0..<Self.size {
                clearedCoords.insert(Coordinate(row: r, col: c))
            }
        }

        // Remove cleared cells from bitboard and grid
        for coord in clearedCoords {
            let bitIndex = coord.row * 8 + coord.col
            bitboard &= ~(UInt64(1) << bitIndex)
            grid[coord.row][coord.col] = nil
        }

        return ClearResult(
            clearedRows: completedRows,
            clearedCols: completedCols,
            clearedCoordinates: clearedCoords
        )
    }

    /// Returns a simulated board without mutating self
    public func simulatingPlacement(piece: Piece, atOriginRow r: Int, originCol c: Int) -> (Board, ClearResult)? {
        var copy = self
        guard let result = copy.place(piece: piece, atOriginRow: r, originCol: c) else {
            return nil
        }
        return (copy, result)
    }

    /// Count of occupied cells on the board
    public var occupiedCellCount: Int {
        bitboard.nonzeroBitCount
    }

    /// Ratio of board vacancy (0.0 full, 1.0 completely empty)
    public var vacancyRatio: Double {
        Double(64 - occupiedCellCount) / 64.0
    }
}
