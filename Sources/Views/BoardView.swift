import SwiftUI

public struct GridGeometry: Equatable {
    public var frame: CGRect = .zero
    public var cellSize: CGFloat = 0

    public init(frame: CGRect = .zero, cellSize: CGFloat = 0) {
        self.frame = frame
        self.cellSize = cellSize
    }
}

public struct GridGeometryPreferenceKey: PreferenceKey {
    public static var defaultValue: GridGeometry = GridGeometry()
    public static func reduce(value: inout GridGeometry, nextValue: () -> GridGeometry) {
        value = nextValue()
    }
}

public struct BoardView: View {
    @ObservedObject var gameState: GameState
    let onGridGeometryChanged: (GridGeometry) -> Void

    public init(gameState: GameState, onGridGeometryChanged: @escaping (GridGeometry) -> Void) {
        self.gameState = gameState
        self.onGridGeometryChanged = onGridGeometryChanged
    }

    public var body: some View {
        GeometryReader { geometry in
            let boardSize = min(geometry.size.width, geometry.size.height)
            let padding: CGFloat = 8
            let boardInnerSize = boardSize - (padding * 2)
            let cellSize = max(10, (boardInnerSize - (CGFloat(Board.size - 1) * 4)) / CGFloat(Board.size))

            ZStack {
                // Background Rounded Card
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(gameState.activeTheme.boardBackground.swiftUIColor)
                    .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)

                // 8x8 Cell Grid
                VStack(spacing: 4) {
                    ForEach(0..<Board.size, id: \.self) { row in
                        HStack(spacing: 4) {
                            ForEach(0..<Board.size, id: \.self) { col in
                                cellView(row: row, col: col, cellSize: cellSize)
                            }
                        }
                    }
                }
                .background(
                    GeometryReader { gridGeo in
                        Color.clear.preference(
                            key: GridGeometryPreferenceKey.self,
                            value: GridGeometry(
                                frame: gridGeo.frame(in: .global),
                                cellSize: cellSize
                            )
                        )
                    }
                )
                .padding(padding)

                // Overlay Praise Message Banner (e.g. "Amazing!", "Cool!")
                if let praise = gameState.latestPraise {
                    Text(praise.rawValue)
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.yellow, Color.orange, Color.red],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 3)
                        .scaleEffect(1.0)
                        .transition(.scale(scale: 0.5).combined(with: .opacity))
                        .id(gameState.praiseId)
                }
            }
            .frame(width: boardSize, height: boardSize)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .aspectRatio(1.0, contentMode: .fit)
        .onPreferenceChange(GridGeometryPreferenceKey.self) { geo in
            if geo.cellSize > 0 && geo.frame.width > 0 {
                onGridGeometryChanged(geo)
            }
        }
    }

    @ViewBuilder
    private func cellView(row: Int, col: Int, cellSize: CGFloat) -> some View {
        let coord = Coordinate(row: row, col: col)
        let isClearing = gameState.animatedClearingCells.contains(coord)
        let occupiedColorIndex = gameState.board.grid[row][col]
        let isGhost = isGhostCell(row: row, col: col)

        ZStack {
            // Base empty cell
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(gameState.activeTheme.emptyCell.swiftUIColor)

            // Occupied tile
            if let colorIndex = occupiedColorIndex {
                let baseColor = gameState.activeTheme.tileColor(for: colorIndex).swiftUIColor

                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [baseColor.opacity(0.85), baseColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1.2)
                    )
                    .scaleEffect(isClearing ? 1.25 : 1.0)
                    .opacity(isClearing ? 0.0 : 1.0)
                    .animation(.easeOut(duration: 0.22), value: isClearing)
            } else if isGhost, let ghostPiece = gameState.ghostPlacement?.piece {
                // Ghost preview cell
                let ghostColor = gameState.activeTheme.tileColor(for: ghostPiece.colorIndex).swiftUIColor

                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(ghostColor.opacity(0.45))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(ghostColor.opacity(0.8), lineWidth: 1.5)
                    )
            }
        }
        .frame(width: cellSize, height: cellSize)
    }

    private func isGhostCell(row: Int, col: Int) -> Bool {
        guard let ghost = gameState.ghostPlacement else { return false }
        for coord in ghost.piece.coordinates {
            if (ghost.originRow + coord.row) == row && (ghost.originCol + coord.col) == col {
                return true
            }
        }
        return false
    }
}
