import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct EasyWidgetEntry: TimelineEntry {
    let date: Date
    let monthlyStats: [Int: Int]
    let month: Int
    let year: Int
    let status: WidgetStatus
    
    enum WidgetStatus {
        case loading
        case success
        case notConfigured
        case error(String)
    }
}

// MARK: - Supabase Configuration
// ⚠️ IMPORTANT: Fill in your Supabase credentials for Widget cloud sync
struct SupabaseConfig {
    // ========================================
    // 👇 SUPABASE CREDENTIALS
    // ========================================
    
    /// Your Supabase project URL
    private static let hardcodedUrl = "https://ncjlkxrsobfdtqpuoqwt.supabase.co"
    
    /// Your Supabase anon/public key
    private static let hardcodedKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jamxreHJzb2JmZHRxcHVvcXd0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgzMDgyODksImV4cCI6MjA4Mzg4NDI4OX0.oSelX276yN-CumrBpbrI1lY5BgSVhJQiER1BGVP8q8Y"
    
    /// ⚠️ Your User ID (copy from App Settings after login)
    /// Example: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    private static let hardcodedUserId = ""
    
    // ========================================
    // 👆 END OF CONFIGURATION
    // ========================================
    
    static var url: String { hardcodedUrl }
    static var anonKey: String { hardcodedKey }
    static var userId: String { hardcodedUserId }
    
    static var isConfigured: Bool {
        return !url.isEmpty && !anonKey.isEmpty && !userId.isEmpty
    }
}

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> EasyWidgetEntry {
        EasyWidgetEntry(
            date: Date(),
            monthlyStats: [1: 2, 5: 1, 10: 3],
            month: Calendar.current.component(.month, from: Date()),
            year: Calendar.current.component(.year, from: Date()),
            status: .success
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (EasyWidgetEntry) -> ()) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let now = Date()
        
        // Check if configured
        guard SupabaseConfig.isConfigured else {
            let entry = EasyWidgetEntry(
                date: now,
                monthlyStats: [:],
                month: Calendar.current.component(.month, from: now),
                year: Calendar.current.component(.year, from: now),
                status: .notConfigured
            )
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
            completion(timeline)
            return
        }
        
        // Fetch from cloud
        fetchFromCloud(date: now) { entry in
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: now)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    // MARK: - Cloud Data Fetching
    private func fetchFromCloud(date: Date, completion: @escaping (EasyWidgetEntry) -> ()) {
        let currentMonth = Calendar.current.component(.month, from: date)
        let currentYear = Calendar.current.component(.year, from: date)
        
        guard let url = URL(string: "\(SupabaseConfig.url)/rest/v1/rpc/get_widget_stats") else {
            completion(EasyWidgetEntry(
                date: date, monthlyStats: [:], month: currentMonth, year: currentYear,
                status: .error("Invalid URL")
            ))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = ["p_user_id": SupabaseConfig.userId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(EasyWidgetEntry(
                    date: date, monthlyStats: [:], month: currentMonth, year: currentYear,
                    status: .error("网络错误")
                ))
                return
            }
            
            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(EasyWidgetEntry(
                    date: date, monthlyStats: [:], month: currentMonth, year: currentYear,
                    status: .error("服务器错误")
                ))
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let month = json["month"] as? Int ?? currentMonth
                let year = json["year"] as? Int ?? currentYear
                var counts: [Int: Int] = [:]
                
                if let countsDict = json["counts"] as? [String: Int] {
                    for (dayString, count) in countsDict {
                        if let day = Int(dayString) {
                            counts[day] = count
                        }
                    }
                }
                
                completion(EasyWidgetEntry(
                    date: date, monthlyStats: counts, month: month, year: year,
                    status: .success
                ))
                return
            }
            
            completion(EasyWidgetEntry(
                date: date, monthlyStats: [:], month: currentMonth, year: currentYear,
                status: .error("解析错误")
            ))
        }.resume()
    }
}

// MARK: - Widget View
struct EasyWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Group {
            switch entry.status {
            case .notConfigured:
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 32))
                        .foregroundColor(.orange)
                    Text("需要配置 User ID")
                        .font(.system(size: 12, weight: .medium))
                    Text("见 EasyWidget.swift")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .error(let message):
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.orange)
                    Text(message)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .loading, .success:
                VStack(alignment: .leading, spacing: 8) {
                    HeatmapGrid(entry: entry)
                    
                    Spacer(minLength: 0)
                    
                    Link(destination: URL(string: "easy://start")!) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(Color(hex: 0x10B981))
                            Text("开始记录")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.primary.opacity(0.06))
                        .cornerRadius(12)
                    }
                }
                .padding(12)
            }
        }
        .widgetBackground()
    }
}

// MARK: - Heatmap Grid
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

// MARK: - Heatmap Cell
struct HeatmapCell: View {
    let count: Int
    let size: CGFloat
    
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

// MARK: - Color Extension
extension Color {
    init(hex: Int) {
        self.init(.sRGB, red: Double((hex >> 16) & 0xff) / 255, green: Double((hex >> 08) & 0xff) / 255, blue: Double((hex >> 00) & 0xff) / 255, opacity: 1)
    }
}

// MARK: - Widget Configuration
struct EasyWidget: Widget {
    let kind: String = "EasyWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EasyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Easy 记录")
        .description("查看本月统计（需配置 User ID）")
        .supportedFamilies([.systemSmall])
        .disableContentMarginsIfAvailable()
    }
}

// MARK: - Widget Configuration Extension
extension WidgetConfiguration {
    func disableContentMarginsIfAvailable() -> some WidgetConfiguration {
        if #available(iOS 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}

// MARK: - Widget Bundle
@main
struct EasyWidgetBundle: WidgetBundle {
    var body: some Widget {
        EasyWidget()
    }
}

// MARK: - View Extension
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
