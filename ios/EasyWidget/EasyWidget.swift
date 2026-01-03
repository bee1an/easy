import WidgetKit
import SwiftUI

struct EasyWidgetEntry: TimelineEntry {
    let date: Date
    let monthlyStats: [Int: Int]
    let month: Int
    let year: Int
    let isRunning: Bool
    let elapsedText: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> EasyWidgetEntry {
        EasyWidgetEntry(date: Date(), monthlyStats: [:], month: 1, year: 2024, isRunning: false, elapsedText: "0:00")
    }

    func getSnapshot(in context: Context, completion: @escaping (EasyWidgetEntry) -> ()) {
        let entry = _getEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = _getEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func _getGroupId() -> String {
        // Fallback to hardcoded ID if something goes wrong
        let fallbackId = "group.com.bee1an.easy"
        
        guard let bundleId = Bundle.main.bundleIdentifier else {
            return fallbackId
        }
        
        // SideStore usually changes IDs to something like [TeamID].com.bee1an.easy
        // or appends a suffix. The App Group usually follows the pattern "group.[BundleID]"
        // If we are in the widget extension, we need to remove the extension suffix
        let baseId = bundleId.replacingOccurrences(of: ".EasyWidget", with: "")
        return "group.\(baseId)"
    }

    private func _getEntry(date: Date) -> EasyWidgetEntry {
        let suiteName = _getGroupId()
        let userDefaults = UserDefaults(suiteName: suiteName)
        
        // Use a default month/year if data is missing or invalid
        var currentMonth = Calendar.current.component(.month, from: date)
        var currentYear = Calendar.current.component(.year, from: date)
        
        let statsJson = userDefaults?.string(forKey: "monthly_stats") ?? ""
        let isRunning = userDefaults?.bool(forKey: "is_running") ?? false
        let elapsedText = userDefaults?.string(forKey: "elapsed_text") ?? (isRunning ? "--:--" : "开始记录")

        var counts: [Int: Int] = [:]

        // Parse JSON data for monthly stats
        if let data = statsJson.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            currentMonth = json["month"] as? Int ?? currentMonth
            currentYear = json["year"] as? Int ?? currentYear
            
            if let countsDict = json["counts"] as? [String: Int] {
                for (dayString, count) in countsDict {
                    if let day = Int(dayString) {
                        counts[day] = count
                    }
                }
            }
        }

        return EasyWidgetEntry(
            date: date,
            monthlyStats: counts,
            month: currentMonth,
            year: currentYear,
            isRunning: isRunning,
            elapsedText: elapsedText
        )
    }
}

struct EasyWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HeatmapGrid(entry: entry)
            
            Spacer(minLength: 0)
            
            Link(destination: URL(string: "easy://start")!) {
                HStack {
                    Image(systemName: entry.isRunning ? "stop.circle.fill" : "play.circle.fill")
                        .foregroundColor(entry.isRunning ? .red : Color(hex: 0x10B981))
                    Text(entry.isRunning ? entry.elapsedText : "开始记录")
                        .font(.system(size: 13, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.primary.opacity(0.06))
                .cornerRadius(12)
            }
        }
        .padding(12)
        .widgetBackground()
    }
}

struct HeatmapGrid: View {
    let entry: EasyWidgetEntry
    
    private let rows = 5
    private let cols = 7
    private let spacing: CGFloat = 4
    
    var body: some View {
        let daysInMonth = getDaysInMonth(month: entry.month, year: entry.year)
        let firstDayOfWeek = getFirstDayOfWeek(month: entry.month, year: entry.year)
        
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let availableHeight = geometry.size.height
            let cellWidth = (availableWidth - spacing * CGFloat(cols - 1)) / CGFloat(cols)
            let cellHeight = (availableHeight - spacing * CGFloat(rows - 1)) / CGFloat(rows)
            let cellSize = min(cellWidth, cellHeight)
            
            VStack(spacing: spacing) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<cols, id: \.self) { col in
                            let dayIndex = (row * cols + col) - firstDayOfWeek + 1
                            if dayIndex > 0 && dayIndex <= daysInMonth {
                                let count = entry.monthlyStats[dayIndex] ?? 0
                                HeatmapCell(count: count, size: cellSize)
                            } else {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.clear)
                                    .frame(width: cellSize, height: cellSize)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func getDaysInMonth(month: Int, year: Int) -> Int {
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    private func getFirstDayOfWeek(month: Int, year: Int) -> Int {
        let dateComponents = DateComponents(year: year, month: month, day: 1)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        let weekday = calendar.component(.weekday, from: date)
        return (weekday - calendar.firstWeekday + 7) % 7
    }
}

struct HeatmapCell: View {
    let count: Int
    let size: CGFloat
    
    // Opacity levels matching Flutter's HeatmapColors
    // [0.0, 0.3, 0.6, 0.85, 1.0]
    private static let opacityLevels: [Double] = [0.0, 0.3, 0.6, 0.85, 1.0]
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(colorForCount(count))
            .frame(width: size, height: size)
    }
    
    private func colorForCount(_ count: Int) -> Color {
        if count == 0 { return Color.primary.opacity(0.08) }
        let primary = Color(hex: 0x10B981)
        let level = min(count, 4)
        return primary.opacity(Self.opacityLevels[level])
    }
}

extension Color {
    init(hex: Int) {
        self.init(.sRGB, red: Double((hex >> 16) & 0xff) / 255, green: Double((hex >> 08) & 0xff) / 255, blue: Double((hex >> 00) & 0xff) / 255, opacity: 1)
    }
}

struct EasyWidget: Widget {
    let kind: String = "EasyWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EasyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Easy 记录")
        .description("快速查看本月统计并开始记录。")
        .supportedFamilies([.systemSmall])
        .disableContentMarginsIfAvailable()
    }
}

extension WidgetConfiguration {
    func disableContentMarginsIfAvailable() -> some WidgetConfiguration {
        if #available(iOS 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}

@main
struct EasyWidgetBundle: WidgetBundle {
    var body: some Widget {
        EasyWidget()
        // If you want Live Activity and Control, you can add them here:
        // EasyWidgetControl()
        // EasyWidgetLiveActivity()
    }
}

extension View {
    func widgetBackground() -> some View {
        if #available(iOS 17.0, *) {
            return containerBackground(for: .widget) {
                Color(UIColor.systemBackground)
            }
        } else {
            return background(Color(UIColor.systemBackground))
        }
    }
}

