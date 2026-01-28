import SwiftUI
import AppKit

struct ContentView: View {
    let columnTitles = ["O", "S", "C", "A", "R"]
    let gridSize = 5
    let borderSize: CGFloat = 16
    @State private var gridData: [[String]] = Array(repeating: Array(repeating: "", count: 5), count: 5)
    @State private var numberOfPDFs: String = "10"

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - (borderSize * 2)
            let availableHeight = geometry.size.height - (borderSize * 2) - 80

            // Calculate font size dynamically (about 1/5 of available width per column)
            let dynamicFontSize = min(availableWidth, availableHeight) / 6.5
            let headerHeight = dynamicFontSize
            let buttonHeight: CGFloat = 80

            // Calculate grid size to keep it square (accounting for header and button)
            let maxGridSize = min(availableWidth, availableHeight - headerHeight - buttonHeight)

            HStack {
                Spacer()
                VStack {
                    Spacer()

                    VStack(spacing: 0) {
                        // Column headers
                        HStack(spacing: 0) {
                            ForEach(0..<gridSize, id: \.self) { col in
                                Text(columnTitles[col])
                                    .font(.custom("Phosphate-Inline", size: dynamicFontSize))
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                                    .frame(width: maxGridSize / CGFloat(gridSize))
                                    .multilineTextAlignment(.center)

                            }
                        }
                        .padding(.bottom, 0)
                        
                        // Grid with text overlay (always square)
                        ZStack {
                            // Grid cell text and images
                            VStack(spacing: 0) {
                                ForEach(0..<gridSize, id: \.self) { row in
                                    HStack(spacing: 0) {
                                        ForEach(0..<gridSize, id: \.self) { col in
                                            // Center square shows Oscar image
                                            if row == 2 && col == 2 {
                                                Image("oscar")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: maxGridSize / CGFloat(gridSize), height: maxGridSize / CGFloat(gridSize))
                                            } else {
                                                Text(gridData[row][col])
                                                    .font(.system(size: maxGridSize / CGFloat(gridSize) / 10))
                                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                                                    .frame(width: maxGridSize / CGFloat(gridSize)-4, height: maxGridSize / CGFloat(gridSize)-4)
                                                    .multilineTextAlignment(.center)
                                                    .lineLimit(nil)
                                                    .minimumScaleFactor(0.5)
                                                    .padding(4)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            GridShape(rows: gridSize, columns: gridSize)
                                .stroke(Color(red: 0.3, green: 0.3, blue: 0.3), lineWidth: 2)
                        }
                        .frame(width: maxGridSize, height: maxGridSize)

                        Spacer()
                            .frame(height: borderSize)

                        // Generate button (below grid)
                        Button(action: generateRandomData) {
                            Text("Generate")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, borderSize)

                        // Text field and Generate and Save button
                        HStack(spacing: 12) {
                            TextField("Number", text: $numberOfPDFs)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                                .multilineTextAlignment(.center)
                                .background(Color.white)
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                                .onSubmit {
                                    generateAndSaveMultiplePDFs()
                                }

                            Button(action: generateAndSaveMultiplePDFs) {
                                Text("Generate and Save")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(Color.green)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 8)
                    }

                    Spacer()
                }
                Spacer()
            }
            .padding(borderSize)
            .background(Color.white)
        }
        .frame(minWidth: 400, minHeight: 400)
        .background(Color.white)
        .onAppear {
            generateRandomData()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PrintRequested"))) { _ in
            printView()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SavePDFRequested"))) { _ in
            saveToPDF()
        }
    }

    func loadDataFromFile() {
        // Load oscar.txt from app bundle
        guard let path = Bundle.main.path(forResource: "oscar", ofType: "txt") else {
            print("Could not find oscar.txt file in bundle")
            return
        }

        print("Loading data from: \(path)")

        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }

            var newData: [[String]] = Array(repeating: Array(repeating: "", count: 5), count: 5)

            for (rowIndex, line) in lines.enumerated() {
                if rowIndex >= gridSize { break }
                let cells = line.components(separatedBy: ",")
                for (colIndex, cell) in cells.enumerated() {
                    if colIndex >= gridSize { break }
                    newData[rowIndex][colIndex] = cell.trimmingCharacters(in: .whitespaces)
                }
            }

            gridData = newData
        } catch {
            print("Error reading file: \(error)")
        }
    }

    func generateRandomData() {
        // Load oscar.txt from app bundle
        guard let path = Bundle.main.path(forResource: "oscar", ofType: "txt") else {
            print("Could not find oscar.txt file in bundle")
            return
        }

        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }

            // Clear the grid first
            var newData: [[String]] = Array(repeating: Array(repeating: "", count: 5), count: 5)

            // Use a mutable copy of lines and randomly pick items one at a time
            var availableLines = lines
            var rng = SystemRandomNumberGenerator()

            // Randomly fill cells (skip center square for Oscar image)
            for row in 0..<gridSize {
                for col in 0..<gridSize {
                    // Skip center square (row 2, col 2)
                    if row == 2 && col == 2 {
                        continue
                    }
                    if !availableLines.isEmpty {
                        // Pick a random index from remaining items
                        let randomIndex = Int.random(in: 0..<availableLines.count, using: &rng)
                        newData[row][col] = availableLines[randomIndex]
                        // Remove the selected item so it won't be used again
                        availableLines.remove(at: randomIndex)
                    }
                }
            }

            gridData = newData
        } catch {
            print("Error reading file: \(error)")
        }
    }

    func printView() {
        // Create a printable view with letter size (8.5 x 11 inches)
        let printInfo = NSPrintInfo()
        printInfo.paperSize = NSSize(width: 612, height: 792) // 8.5" x 11" in points (72 points per inch)
        printInfo.topMargin = 36
        printInfo.bottomMargin = 36
        printInfo.leftMargin = 36
        printInfo.rightMargin = 36
        printInfo.orientation = .portrait

        // Set frame to printable area
        let printableWidth = printInfo.paperSize.width - printInfo.leftMargin - printInfo.rightMargin
        let printableHeight = printInfo.paperSize.height - printInfo.topMargin - printInfo.bottomMargin

        // Create a custom NSView for printing
        let printView = PrintableNSView(
            frame: NSRect(x: 0, y: 0, width: printableWidth, height: printableHeight),
            columnTitles: columnTitles,
            gridSize: gridSize,
            gridData: gridData
        )

        let printOperation = NSPrintOperation(view: printView, printInfo: printInfo)
        printOperation.showsPrintPanel = true
        printOperation.showsProgressPanel = true
        printOperation.run()
    }

    func saveToPDF() {
        // Create a printable view with letter size (8.5 x 11 inches)
        let printInfo = NSPrintInfo()
        printInfo.paperSize = NSSize(width: 612, height: 792) // 8.5" x 11" in points (72 points per inch)
        printInfo.topMargin = 36
        printInfo.bottomMargin = 36
        printInfo.leftMargin = 36
        printInfo.rightMargin = 36
        printInfo.orientation = .portrait

        // Set frame to printable area
        let printableWidth = printInfo.paperSize.width - printInfo.leftMargin - printInfo.rightMargin
        let printableHeight = printInfo.paperSize.height - printInfo.topMargin - printInfo.bottomMargin

        // Create a custom NSView for printing
        let printView = PrintableNSView(
            frame: NSRect(x: 0, y: 0, width: printableWidth, height: printableHeight),
            columnTitles: columnTitles,
            gridSize: gridSize,
            gridData: gridData
        )

        // Show save panel
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        savePanel.nameFieldStringValue = "OSCAR.pdf"

        if savePanel.runModal() == .OK, let url = savePanel.url {
            // Create PDF data
            let pdfData = printView.dataWithPDF(inside: printView.bounds)

            // Write to file
            do {
                try pdfData.write(to: url)
            } catch {
                print("Error saving PDF: \(error)")
            }
        }
    }

    func generateAndSaveMultiplePDFs() {
        // Parse the number of PDFs to generate
        guard let count = Int(numberOfPDFs), count > 0 else {
            print("Invalid number of PDFs. Please enter a positive integer.")
            return
        }

        // Show folder selection dialog
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.prompt = "Select Folder"
        openPanel.message = "Select a folder to save the PDFs"

        if openPanel.runModal() == .OK, let folderURL = openPanel.url {
            // Set up print info for PDF generation
            let printInfo = NSPrintInfo()
            printInfo.paperSize = NSSize(width: 612, height: 792) // 8.5" x 11"
            printInfo.topMargin = 36
            printInfo.bottomMargin = 36
            printInfo.leftMargin = 36
            printInfo.rightMargin = 36
            printInfo.orientation = .portrait

            let printableWidth = printInfo.paperSize.width - printInfo.leftMargin - printInfo.rightMargin
            let printableHeight = printInfo.paperSize.height - printInfo.topMargin - printInfo.bottomMargin

            // Load data once to avoid repeated file reads
            guard let path = Bundle.main.path(forResource: "oscar", ofType: "txt") else {
                print("Could not find oscar.txt file in bundle")
                return
            }

            do {
                let content = try String(contentsOfFile: path, encoding: .utf8)
                let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }

                // Generate and save each PDF
                for i in 1...count {
                    // Generate random grid data with improved randomness
                    var newData: [[String]] = Array(repeating: Array(repeating: "", count: 5), count: 5)

                    // Use a fresh mutable copy for each PDF and randomly pick items
                    var availableLines = lines
                    var rng = SystemRandomNumberGenerator()

                    for row in 0..<gridSize {
                        for col in 0..<gridSize {
                            // Skip center square (row 2, col 2)
                            if row == 2 && col == 2 {
                                continue
                            }
                            if !availableLines.isEmpty {
                                // Pick a random index from remaining items
                                let randomIndex = Int.random(in: 0..<availableLines.count, using: &rng)
                                newData[row][col] = availableLines[randomIndex]
                                // Remove the selected item so it won't be used again
                                availableLines.remove(at: randomIndex)
                            }
                        }
                    }

                    // Create printable view with this grid data
                    let printView = PrintableNSView(
                        frame: NSRect(x: 0, y: 0, width: printableWidth, height: printableHeight),
                        columnTitles: columnTitles,
                        gridSize: gridSize,
                        gridData: newData
                    )

                    // Create PDF data
                    let pdfData = printView.dataWithPDF(inside: printView.bounds)

                    // Create file URL with naming pattern OSCAR_<i>.pdf
                    let fileName = "OSCAR_\(i).pdf"
                    let fileURL = folderURL.appendingPathComponent(fileName)

                    // Write to file
                    try pdfData.write(to: fileURL)
                    print("Saved: \(fileName)")
                }

                print("Successfully generated and saved \(count) PDFs")
            } catch {
                print("Error generating PDFs: \(error)")
            }
        }
    }
}

class PrintableNSView: NSView {
    let columnTitles: [String]
    let gridSize: Int
    let gridData: [[String]]
    let borderSize: CGFloat = 16

    init(frame: NSRect, columnTitles: [String], gridSize: Int, gridData: [[String]]) {
        self.columnTitles = columnTitles
        self.gridSize = gridSize
        self.gridData = gridData
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Fill with white background
        NSColor.white.setFill()
        dirtyRect.fill()

        let availableWidth = bounds.width - (borderSize * 2)
        let availableHeight = bounds.height - (borderSize * 2)

        // Calculate font size dynamically
        let dynamicFontSize = min(availableWidth, availableHeight) / 6.5
        let headerHeight = dynamicFontSize * 1.1

        // Calculate grid size to keep it square
        let maxGridSize = min(availableWidth, availableHeight - headerHeight)

        // Center the content
        let contentX = (bounds.width - maxGridSize) / 2
        let contentY = (bounds.height - maxGridSize - headerHeight) / 2

        // Set up font and color
        let font = NSFont(name: "Phosphate-Inline", size: dynamicFontSize) ?? NSFont.systemFont(ofSize: dynamicFontSize)
        let textColor = NSColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]

        // Draw column titles (above the grid)
        let cellWidth = maxGridSize / CGFloat(gridSize)
        for (index, title) in columnTitles.enumerated() {
            let titleString = NSAttributedString(string: title, attributes: attributes)
            let titleSize = titleString.size()
            let titleX = contentX + (CGFloat(index) * cellWidth) + (cellWidth - titleSize.width) / 2
            let titleY = contentY + 4 // Position above grid with small spacing
            titleString.draw(at: NSPoint(x: titleX, y: titleY))
        }

        // Draw grid (below the titles)
        let gridRect = NSRect(x: contentX, y: contentY + headerHeight, width: maxGridSize, height: maxGridSize)
        let gridColor = NSColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        gridColor.setStroke()

        let gridPath = NSBezierPath()
        gridPath.lineWidth = 2.0

        // Draw vertical lines
        for col in 0...gridSize {
            let x = gridRect.minX + (CGFloat(col) * cellWidth)
            gridPath.move(to: NSPoint(x: x, y: gridRect.minY))
            gridPath.line(to: NSPoint(x: x, y: gridRect.maxY))
        }

        // Draw horizontal lines
        let cellHeight = maxGridSize / CGFloat(gridSize)
        for row in 0...gridSize {
            let y = gridRect.minY + (CGFloat(row) * cellHeight)
            gridPath.move(to: NSPoint(x: gridRect.minX, y: y))
            gridPath.line(to: NSPoint(x: gridRect.maxX, y: y))
        }

        gridPath.stroke()

        // Draw cell text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                // Calculate available cell area
                let availableCellRect = NSRect(
                    x: gridRect.minX + (CGFloat(col) * cellWidth) + 8,
                    y: gridRect.minY + (CGFloat(row) * cellHeight) + 8,
                    width: cellWidth - 16,
                    height: cellHeight - 16
                )

                // Draw Oscar image in center square
                if row == 2 && col == 2 {
                    if let image = NSImage(named: "oscar") {
                        // Draw image centered in cell with padding
                        let imagePadding: CGFloat = 8
                        let imageRect = NSRect(
                            x: availableCellRect.minX + imagePadding,
                            y: availableCellRect.minY + imagePadding,
                            width: availableCellRect.width - (imagePadding * 2),
                            height: availableCellRect.height - (imagePadding * 2)
                        )
                        image.draw(in: imageRect)
                    }
                } else {
                    let cellText = gridData[row][col]
                    if !cellText.isEmpty {
                        // Start with initial font size and reduce until text fits
                        var fontSize = cellWidth / 10
                        let minFontSize: CGFloat = 6
                        var textSize = CGSize.zero
                        var cellString: NSAttributedString!

                        repeat {
                            let cellFont = NSFont.systemFont(ofSize: fontSize)
                            let wrappedAttributes: [NSAttributedString.Key: Any] = [
                                .font: cellFont,
                                .foregroundColor: textColor,
                                .paragraphStyle: paragraphStyle
                            ]

                            cellString = NSAttributedString(string: cellText, attributes: wrappedAttributes)

                            textSize = cellString.boundingRect(
                                with: NSSize(width: availableCellRect.width, height: CGFloat.greatestFiniteMagnitude),
                                options: [.usesLineFragmentOrigin, .usesFontLeading]
                            ).size

                            // Add small buffer (2 points) to account for line spacing and descenders
                            // If text fits with buffer or we're at minimum font size, break
                            if textSize.height + 2 <= availableCellRect.height || fontSize <= minFontSize {
                                break
                            }

                            // Reduce font size
                            fontSize -= 0.5
                        } while fontSize >= minFontSize

                        // Center vertically within the cell, but use full available height for drawing
                        let yOffset = max(0, (availableCellRect.height - textSize.height) / 2)
                        let centeredRect = NSRect(
                            x: availableCellRect.minX,
                            y: availableCellRect.minY + yOffset,
                            width: availableCellRect.width,
                            height: availableCellRect.height - yOffset
                        )

                        cellString.draw(in: centeredRect)
                    }
                }
            }
        }
    }

    override var isFlipped: Bool {
        return true
    }
}

struct GridShape: Shape {
    let rows: Int
    let columns: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let cellWidth = rect.width / CGFloat(columns)
        let cellHeight = rect.height / CGFloat(rows)

        // Draw vertical lines
        for col in 0...columns {
            let x = rect.minX + (CGFloat(col) * cellWidth)
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
        }

        // Draw horizontal lines
        for row in 0...rows {
            let y = rect.minY + (CGFloat(row) * cellHeight)
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }

        return path
    }
}

#Preview {
    ContentView()
        .frame(width: 500, height: 600)
}
