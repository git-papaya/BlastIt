import SwiftUI

public struct FloatingPieceView: View {
    public let piece: Piece
    public let visualCenter: CGPoint
    public let cellSize: CGFloat
    public let cellSpacing: CGFloat
    public let theme: GameTheme

    public init(
        piece: Piece,
        visualCenter: CGPoint,
        cellSize: CGFloat,
        cellSpacing: CGFloat = 4.0,
        theme: GameTheme
    ) {
        self.piece = piece
        self.visualCenter = visualCenter
        self.cellSize = cellSize
        self.cellSpacing = cellSpacing
        self.theme = theme
    }

    public var body: some View {
        let baseColor = theme.tileColor(for: piece.colorIndex).swiftUIColor
        let bounds = piece.bounds
        let blockW = CGFloat(bounds.width)
        let blockH = CGFloat(bounds.height)
        let totalW = blockW * cellSize + max(0, blockW - 1) * cellSpacing
        let totalH = blockH * cellSize + max(0, blockH - 1) * cellSpacing

        ZStack {
            ForEach(piece.coordinates, id: \.self) { coord in
                let relCol = CGFloat(coord.col - bounds.minCol)
                let relRow = CGFloat(coord.row - bounds.minRow)
                let cellX = relCol * (cellSize + cellSpacing) + cellSize / 2.0 - totalW / 2.0
                let cellY = relRow * (cellSize + cellSpacing) + cellSize / 2.0 - totalH / 2.0

                RoundedRectangle(cornerRadius: max(4.0, cellSize * 0.22), style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [baseColor.opacity(0.85), baseColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: max(4.0, cellSize * 0.22), style: .continuous)
                            .strokeBorder(Color.white.opacity(0.4), lineWidth: 1.2)
                    )
                    .frame(width: cellSize, height: cellSize)
                    .offset(x: cellX, y: cellY)
            }
        }
        .frame(width: totalW, height: totalH)
        .shadow(color: Color.black.opacity(0.45), radius: 14, x: 0, y: 10)
        .scaleEffect(1.08)
        .position(visualCenter)
        .allowsHitTesting(false)
    }
}
