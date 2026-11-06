import Foundation

public struct Coordinate: Hashable, Equatable, Codable {
    public let row: Int
    public let col: Int

    public init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
}

public enum PieceShape: String, CaseIterable, Codable {
    // 1-cell
    case dot1x1
    
    // Lines
    case line2H, line2V
    case line3H, line3V
    case line4H, line4V
    case line5H, line5V
    
    // Squares
    case square2x2
    case square3x3
    
    // Small Corners (3 cells)
    case corner2x2_TL, corner2x2_TR, corner2x2_BL, corner2x2_BR
    
    // Big Corners (5 cells)
    case corner3x3_TL, corner3x3_TR, corner3x3_BL, corner3x3_BR
    
    // L-Shapes (4 cells: 3x2)
    case lShape_0, lShape_90, lShape_180, lShape_270
    case jShape_0, jShape_90, jShape_180, jShape_270
    
    // T-Shapes (4 cells)
    case tShape_Up, tShape_Down, tShape_Left, tShape_Right
    
    // Z & S shapes (4 cells)
    case zShape_H, zShape_V
    case sShape_H, sShape_V
    
    // Cross / Plus (5 cells)
    case plus3x3

    public var coordinates: [Coordinate] {
        switch self {
        case .dot1x1:
            return [Coordinate(row: 0, col: 0)]
            
        case .line2H:
            return [Coordinate(row: 0, col: 0), Coordinate(row: 0, col: 1)]
        case .line2V:
            return [Coordinate(row: 0, col: 0), Coordinate(row: 1, col: 0)]
            
        case .line3H:
            return (0..<3).map { Coordinate(row: 0, col: $0) }
        case .line3V:
            return (0..<3).map { Coordinate(row: $0, col: 0) }
            
        case .line4H:
            return (0..<4).map { Coordinate(row: 0, col: $0) }
        case .line4V:
            return (0..<4).map { Coordinate(row: $0, col: 0) }
            
        case .line5H:
            return (0..<5).map { Coordinate(row: 0, col: $0) }
        case .line5V:
            return (0..<5).map { Coordinate(row: $0, col: 0) }
            
        case .square2x2:
            return [
                Coordinate(row: 0, col: 0), Coordinate(row: 0, col: 1),
                Coordinate(row: 1, col: 0), Coordinate(row: 1, col: 1)
            ]
            
        case .square3x3:
            var coords = [Coordinate]()
            for r in 0..<3 {
                for c in 0..<3 {
                    coords.append(Coordinate(row: r, col: c))
                }
            }
            return coords
            
        case .corner2x2_TL:
            return [Coordinate(row: 0, col: 0), Coordinate(row: 0, col: 1), Coordinate(row: 1, col: 0)]
        case .corner2x2_TR:
            return [Coordinate(row: 0, col: 0), Coordinate(row: 0, col: 1), Coordinate(row: 1, col: 1)]
        case .corner2x2_BL:
            return [Coordinate(row: 0, col: 0), Coordinate(row: 1, col: 0), Coordinate(row: 1, col: 1)]
        case .corner2x2_BR:
            return [Coordinate(row: 0, col: 1), Coordinate(row: 1, col: 0), Coordinate(row: 1, col: 1)]
            
        case .corner3x3_TL:
            return [
                Coordinate(row: 0, col: 0), Coordinate(row: 0, col: 1), Coordinate(row: 0, col: 2),
                Coordinate(row: 1, col: 0), Coordinate(row: 2, col: 0)
            ]
        case .corner3x3_TR:
            return [
                Coordinate(row: 0, col: 0), Coordinate(row: 0, col: 1), Coordinate(row: 0, col: 2),
                Coordinate(row: 1, col: 2), Coordinate(row: 2, col: 2)
            ]
        case .corner3x3_BL:
            return [
                Coordinate(row: 0, col: 0), Coordinate(row: 1, col: 0), Coordinate(row: 2, col: 0),
                Coordinate(row: 2, col: 1), Coordinate(row: 2, col: 2)
            ]
        case .corner3x3_BR:
            return [
                Coordinate(row: 2, col: 0), Coordinate(row: 2, col: 1), Coordinate(row: 2, col: 2),
                Coordinate(row: 0, col: 2), Coordinate(row: 1, col: 2)
            ]
            
        case .lShape_0:
            return [Coordinate(row: 0, col: 0), Coordinate(row: 1, col: 0), Coordinate(row: 2, col: 0), Coordinate(row: 2, col: 1)]
        case .lShape_90:
            return [Coordinate(row: 0, col: 0), Coordinate(row: 0, col: 1), Coordinate(row: 0, col: 2), Coordinate(row: 1, col: 0)]
        case .lShape_180:
            return [Coordinate(row: 0, col: 0), Coordinate(row: 0, col: 1), Coordinate(row: 1, col: 1), Coordinate(row: 2, col: 1)]
        case .lShape_270:
            return [Coordinate(row: 0, col: 2), Coordinate(row: 1, col: 0), Coordinate(row: 1, col: 1), Coordinate(row: 1, col: 2)]
            
        case .jShape_0:
            return [Coordinate(row: 0, col: 1), Coordinate(row: 1, col: 1), Coordinate(row: 2, col: 1), Coordinate(row: 2, col: 0)]
        case .jShape_90:
            return [Coordinate(row: 0, col: 0), Coordinate(row: 1, col: 0), Coordinate(row: 1, col: 1), Coordinate(row: 1, col: 2)]
        case .jShape_180:
            return [Coordinate(row: 0, col: 0), Coordinate(row: 0, col: 1), Coordinate(row: 1, col: 0), Coordinate(row: 2, col: 0)]
        case .jShape_270:
            return [Coordinate(row: 0, col: 0), Coordinate(row: 0, col: 1), Coordinate(row: 0, col: 2), Coordinate(row: 1, col: 2)]
            
        case .tShape_Up:
            return [Coordinate(row: 0, col: 1), Coordinate(row: 1, col: 0), Coordinate(row: 1, col: 1), Coordinate(row: 1, col: 2)]
        case .tShape_Down:
            return [Coordinate(row: 0, col: 0), Coordinate(row: 0, col: 1), Coordinate(row: 0, col: 2), Coordinate(row: 1, col: 1)]
        case .tShape_Left:
            return [Coordinate(row: 0, col: 1), Coordinate(row: 1, col: 0), Coordinate(row: 1, col: 1), Coordinate(row: 2, col: 1)]
        case .tShape_Right:
            return [Coordinate(row: 0, col: 0), Coordinate(row: 1, col: 0), Coordinate(row: 1, col: 1), Coordinate(row: 2, col: 0)]
            
        case .zShape_H:
            return [Coordinate(row: 0, col: 0), Coordinate(row: 0, col: 1), Coordinate(row: 1, col: 1), Coordinate(row: 1, col: 2)]
        case .zShape_V:
            return [Coordinate(row: 0, col: 1), Coordinate(row: 1, col: 0), Coordinate(row: 1, col: 1), Coordinate(row: 2, col: 0)]
            
        case .sShape_H:
            return [Coordinate(row: 0, col: 1), Coordinate(row: 0, col: 2), Coordinate(row: 1, col: 0), Coordinate(row: 1, col: 1)]
        case .sShape_V:
            return [Coordinate(row: 0, col: 0), Coordinate(row: 1, col: 0), Coordinate(row: 1, col: 1), Coordinate(row: 2, col: 1)]
            
        case .plus3x3:
            return [
                Coordinate(row: 0, col: 1),
                Coordinate(row: 1, col: 0), Coordinate(row: 1, col: 1), Coordinate(row: 1, col: 2),
                Coordinate(row: 2, col: 1)
            ]
        }
    }
}

public struct Piece: Identifiable, Equatable, Codable {
    public let id: UUID
    public let shape: PieceShape
    public let coordinates: [Coordinate]
    public let colorIndex: Int

    public var width: Int {
        let maxCol = coordinates.map(\.col).max() ?? 0
        return maxCol + 1
    }

    public var height: Int {
        let maxRow = coordinates.map(\.row).max() ?? 0
        return maxRow + 1
    }

    public var cellCount: Int {
        coordinates.count
    }

    public init(id: UUID = UUID(), shape: PieceShape, colorIndex: Int) {
        self.id = id
        self.shape = shape
        self.coordinates = shape.coordinates
        self.colorIndex = colorIndex
    }

    /// Converts piece coordinates placed at `(originRow, originCol)` to a 64-bit mask.
    /// Returns nil if any coordinate falls outside the 8x8 grid.
    public func bitmask(atOriginRow originRow: Int, originCol: Int) -> UInt64? {
        var mask: UInt64 = 0
        for coord in coordinates {
            let r = originRow + coord.row
            let c = originCol + coord.col
            if r < 0 || r >= 8 || c < 0 || c >= 8 {
                return nil
            }
            let bitIndex = r * 8 + c
            mask |= (UInt64(1) << bitIndex)
        }
        return mask
    }
}
