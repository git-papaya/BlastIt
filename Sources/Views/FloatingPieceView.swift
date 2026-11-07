import SwiftUI

public struct FloatingPieceView: View {
    public let piece: Piece
    public let touchLocation: CGPoint
    public let cellSize: CGFloat
    public let theme: GameTheme

    private let verticalOffset: CGFloat = -60.0
    private let spacing: CGFloat = 4.0

    public init(piece: Piece, touchLocation: CGPoint, cellSize: CGFloat, theme: GameTheme) {
        self.piece = piece
        self.touchLocation = touchLocation
        self.cellSize = cellSize
        self.theme = theme
    }

    public var body: some View {
        let baseColor = theme.tileColor(for: piece.colorIndex).swiftUIColor
        let step = cellSize + spacing

        ZStack {
            ForEach(piece.coordinates, id: \.self) { coord in
                let cellX = (CGFloat(coord.col) - CGFloat(piece.width - 1) / 2.0) * step
                let cellY = (CGFloat(coord.row) - CGFloat(piece.height - 1) / 2.0) * step

                RoundedRectangle(cornerRadius: max(4, cellSize * 0.22), style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [baseColor.opacity(0.85), baseColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: max(4, cellSize * 0.22), style: .continuous)
                            .strokeBorder(Color.white.opacity(0.4), lineWidth: 1.2)
                    )
                    .frame(width: cellSize, height: cellSize)
                    .offset(x: cellX, y: cellY)
            }
        }
        .shadow(color: Color.black.opacity(0.45), radius: 14, x: 0, y: 10)
        .position(x: touchLocation.x, y: touchLocation.y + verticalOffset)
        .allowsHitTesting(false)
    }
}
