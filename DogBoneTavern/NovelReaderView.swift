import SwiftUI
import UniformTypeIdentifiers

struct NovelReaderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = "请选择 SillyTavern 导出的 .jsonl / .json / .txt 聊天记录。"
    @State private var showPicker = false
    @State private var showCopied = false
    @State private var exportURL: URL?

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(text)
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .navigationTitle("📖 小说化阅读器")
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("关闭") { dismiss() }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("导入") { showPicker = true }
                    Button("复制") {
                        UIPasteboard.general.string = text
                        showCopied = true
                    }
                    ShareLink("导出", item: makeExportFile())
                }
            }
            .sheet(isPresented: $showPicker) {
                DocumentPicker { url in
                    readFile(url)
                    showPicker = false
                }
            }
            .alert("已复制小说文本", isPresented: $showCopied) {
                Button("好") {}
            }
        }
    }

    private func readFile(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let raw = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .gb18030) ?? ""
            let parsed = NovelParser.buildContinuousNovel(from: raw)
            text = parsed.isEmpty ? "没有解析到可小说化的内容。请确认文件是 SillyTavern 导出的 .jsonl / .json / .txt 聊天记录。" : parsed
        } catch {
            text = "读取失败：\(error.localizedDescription)"
        }
    }

    private func makeExportFile() -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("酒馆小说化_\(Int(Date().timeIntervalSince1970)).txt")
        try? text.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}

extension String.Encoding {
    static let gb18030 = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)))
}
