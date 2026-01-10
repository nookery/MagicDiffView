import SwiftUI

/// 综合演示视图 - 展示所有演示文件
public struct ComprehensiveDemoView: View {
    @StateObject private var dataManager = DemoDataManager.shared
    @State private var selectedLanguage: DemoCodeLanguage?
    @State private var selectedDemoFile: DemoFile?
    @State private var searchText: String = ""
    @State private var showStatistics = false

    public init() {}

    public var body: some View {
        NavigationSplitView {
            // 侧边栏：文件浏览器
            sidebar
        } detail: {
            // 主内容区域
            contentView
        }
        .navigationTitle("MagicDiffView 演示")
    }

    // MARK: - 侧边栏

    private var sidebar: some View {
        VStack(spacing: 0) {
            // 搜索栏
            searchBar

            // 语言过滤器
            languageFilter

            // 文件列表
            if filteredFiles.isEmpty {
                emptyState
            } else {
                fileList
            }

            // 统计信息按钮
            statisticsButton
        }
        .navigationTitle("演示文件")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Menu {
                    Button("全部展开") {
                        // 可以添加展开全部的逻辑
                    }
                    Button("全部折叠") {
                        // 可以添加折叠全部的逻辑
                    }
                    Divider()
                    Button("显示统计") {
                        showStatistics = true
                    }
                } label: {
                    Label("选项", systemImage: "ellipsis.circle")
                }
            }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("搜索演示文件", text: $searchText)
                .textFieldStyle(.plain)

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color(.controlBackgroundColor))
    }

    private var languageFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                LanguageFilterButton(
                    language: nil,
                    isSelected: selectedLanguage == nil,
                    action: { selectedLanguage = nil }
                )

                ForEach(dataManager.availableLanguages, id: \.self) { language in
                    LanguageFilterButton(
                        language: language,
                        isSelected: selectedLanguage == language,
                        action: { selectedLanguage = language }
                    )
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .background(Color(.controlBackgroundColor))
    }

    private var fileList: some View {
        List(filteredFiles, selection: $selectedDemoFile) { file in
            FileRow(file: file)
                .tag(file)
                .listRowBackground(
                    selectedDemoFile?.id == file.id
                        ? Color.accentColor.opacity(0.1)
                        : Color.clear
                )
        }
        .listStyle(.sidebar)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("未找到匹配的文件")
                .font(.headline)

            Text("尝试调整搜索词或筛选条件")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var statisticsButton: some View {
        Button(action: { showStatistics = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("演示文件")
                        .font(.caption)
                    Text("\(dataManager.statistics.totalFiles) 个文件")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chart.bar.fill")
                    .font(.caption)
            }
            .padding()
            .background(Color(.controlBackgroundColor))
        }
        .buttonStyle(.plain)
    }

    // MARK: - 内容视图

    private var contentView: some View {
        Group {
            if let file = selectedDemoFile {
                demoDetailView(for: file)
            } else {
                welcomeView
            }
        }
        .sheet(isPresented: $showStatistics) {
            StatisticsView()
        }
    }

    private func demoDetailView(for file: DemoFile) -> some View {
        VStack(spacing: 0) {
            // 文件信息头部
            fileHeader(file)

            // Diff 视图（自带工具栏和视图模式切换）
            MagicDiffView(
                oldText: file.beforeContent,
                newText: file.afterContent,
                showLineNumbers: true,
                font: .system(.body, design: .monospaced),
                enableCollapsing: true,
                minUnchangedLines: 3,
                verbose: false,
                initialTheme: .auto
            )
        }
    }

    private func fileHeader(_ file: DemoFile) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: file.language.icon)
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(file.name)
                        .font(.headline)

                    Text(file.language.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Text(file.description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.controlBackgroundColor))
    }

    private var welcomeView: some View {
        VStack(spacing: 24) {
            Image(systemName: "doc.on.doc")
                .font(.system(size: 64))
                .foregroundStyle(Color.accentColor)

            VStack(spacing: 8) {
                Text("欢迎使用 MagicDiffView")
                    .font(.title)

                Text("从左侧选择一个演示文件开始查看")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(
                    icon: "square.split.2x2",
                    title: "并排视图",
                    description: "左右对比旧版本和新版本代码"
                )

                FeatureRow(
                    icon: "text.alignleft",
                    title: "统一差异",
                    description: "经典的 Git 风格差异视图"
                )

                FeatureRow(
                    icon: "paintbrush",
                    title: "主题切换",
                    description: "支持自动、浅色、深色主题"
                )

                FeatureRow(
                    icon: "chevron.compact.up",
                    title: "代码折叠",
                    description: "自动折叠未变更的代码块"
                )

                FeatureRow(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Myers 算法",
                    description: "业界标准的差异计算算法"
                )
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(12)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 计算属性

    private var filteredFiles: [DemoFile] {
        var files = dataManager.demoFiles

        // 语言筛选
        if let language = selectedLanguage {
            files = files.filter { $0.language == language }
        }

        // 搜索筛选
        if !searchText.isEmpty {
            files = dataManager.searchFiles(query: searchText)
            // 再次应用语言筛选
            if let language = selectedLanguage {
                files = files.filter { $0.language == language }
            }
        }

        return files
    }
}

// MARK: - 文件行视图

struct FileRow: View {
    let file: DemoFile

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: file.language.icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.body)

                Text(file.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(file.language.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 语言过滤器按钮

struct LanguageFilterButton: View {
    let language: DemoCodeLanguage?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(language?.rawValue ?? "全部")
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.controlBackgroundColor))
                .foregroundStyle(isSelected ? .white : .primary)
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 功能行

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

// MARK: - 统计视图

struct StatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = DemoDataManager.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 总览卡片
                OverviewCard(
                    totalFiles: dataManager.statistics.totalFiles,
                    totalLines: dataManager.statistics.totalLines
                )

                // 语言分布
                LanguageDistribution(languageCounts: dataManager.statistics.languageCounts)

                Spacer()
            }
            .padding()
            .navigationTitle("统计信息")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .frame(width: 400, height: 500)
    }
}

struct OverviewCard: View {
    let totalFiles: Int
    let totalLines: Int

    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(totalFiles)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.accentColor)

                Text("演示文件")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .frame(height: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(totalLines)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.accentColor)

                Text("总代码行数")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct LanguageDistribution: View {
    let languageCounts: [DemoCodeLanguage: Int]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("语言分布")
                .font(.headline)

            ForEach(Array(languageCounts.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { language in
                if let count = languageCounts[language] {
                    LanguageBar(language: language, count: count)
                }
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct LanguageBar: View {
    let language: DemoCodeLanguage
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: language.icon)
                    .font(.caption)
                Text(language.rawValue)
                    .font(.caption)
                Spacer()
                Text("\(count) 个文件")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(width: geometry.size.width * 0.7)

                    Rectangle()
                        .fill(Color(.separatorColor))
                        .frame(width: geometry.size.width * 0.3)
                }
            }
            .frame(height: 4)
            .cornerRadius(2)
        }
    }
}

// MARK: - 预览

#Preview {
    ComprehensiveDemoView()
}
