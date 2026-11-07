import CoreGraphics
import Foundation

/// Pure-logic coordinate and placement math for Block Blast board geometry and drag targeting.
public enum BoardLayout {

    /// Computes safe row/col scan ranges for candidate piece placements.
    /// Returns nil if the drag point is so far outside the board that no candidate can exist.
    public static func placementSearchRanges(
        centerRow: Int,
        centerCol: Int,
        searchRadius: Int,
        gridSize: Int = 8
    ) -> (rows: ClosedRange<Int>, cols: ClosedRange<Int>)? {
        let lowerRow = max(0, centerRow - searchRadius)
        let upperRow = min(gridSize - 1, centerRow + searchRadius)
        let lowerCol = max(0, centerCol - searchRadius)
        let upperCol = min(gridSize - 1, centerCol + searchRadius)
        guard lowerRow <= upperRow, lowerCol <= upperCol else { return nil }
        return (lowerRow...upperRow, lowerCol...upperCol)
    }

    /// Computes adaptive upward lift above the touch point.
    /// Full baseOffset away from top edge, smoothly tapering to 0 at the top edge of the board.
    public static func adaptiveLiftOffset(fingerGridY: CGFloat, baseOffset: CGFloat) -> CGFloat {
        guard baseOffset > 0 else { return 0 }
        return min(baseOffset, max(0, fingerGridY))
    }

    /// Computes the grid-local visual center of a piece when placed at (originRow, originCol).
    public static func blockCenter(
        for piece: Piece,
        atOriginRow row: Int,
        originCol col: Int,
        cellSize: CGFloat,
        cellSpacing: CGFloat = 4.0
    ) -> CGPoint {
        let bounds = piece.bounds
        let step = cellSize + cellSpacing
        let centerRow = CGFloat(row) + CGFloat(bounds.maxRow + bounds.minRow) / 2.0
        let centerCol = CGFloat(col) + CGFloat(bounds.maxCol + bounds.minCol) / 2.0
        return CGPoint(
            x: centerCol * step + cellSize / 2.0,
            y: centerRow * step + cellSize / 2.0
        )
    }

    /// Finds candidate (row, col) minimizing Euclidean distance between piece visual center
    /// and `nearPoint` (grid-relative center of dragged piece), constrained by maxDistance and canPlace.
    public static func findOptimalPlacement(
        for piece: Piece,
        nearPoint: CGPoint,
        cellSize: CGFloat,
        cellSpacing: CGFloat = 4.0,
        gridSize: Int = 8,
        maxDistance: CGFloat = 280.0,
        canPlace: (Piece, Int, Int) -> Bool
    ) -> (row: Int, col: Int)? {
        let step = cellSize + cellSpacing
        guard step > 0 else { return nil }

        let bounds = piece.bounds
        let centerRow = Int(nearPoint.y / step)
        let centerCol = Int(nearPoint.x / step)
        let searchRadius = max(bounds.width, bounds.height) + 2

        guard let ranges = placementSearchRanges(
            centerRow: centerRow,
            centerCol: centerCol,
            searchRadius: searchRadius,
            gridSize: gridSize
        ) else {
            return nil
        }

        var bestPosition: (row: Int, col: Int)?
        var bestDistance = CGFloat.greatestFiniteMagnitude

        for row in ranges.rows {
            for col in ranges.cols {
                guard canPlace(piece, row, col) else { continue }

                let center = blockCenter(
                    for: piece,
                    atOriginRow: row,
                    originCol: col,
                    cellSize: cellSize,
                    cellSpacing: cellSpacing
                )
                let distance = hypot(center.x - nearPoint.x, center.y - nearPoint.y)

                if distance < bestDistance && distance <= maxDistance {
                    bestDistance = distance
                    bestPosition = (row, col)
                }
            }
        }

        return bestPosition
    }
}
