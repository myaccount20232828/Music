import SwiftUI

struct LogView: View {
    @State var LogItems: [LogItem] = []
    let pipe = Pipe()
    let sema = DispatchSemaphore(value: 0)
    var body: some View {
        ScrollView {
            ScrollViewReader { scroll in
                VStack(alignment: .leading) {
                    ForEach(LogItems) { Item in
                        Text(Item.Message.lineFix())
                        .font(.system(size: 15, weight: .regular, design: .monospaced))
                        .foregroundColor(.white)
                        .id(Item.id)
                    }
                }
                .onChange(of: LogItems) { _ in
                    DispatchQueue.main.async {
                        scroll.scrollTo(LogItems.last?.id, anchor: .bottom)
                    }
                }
                .contextMenu {
                    Button {
                        var LogString = ""
                        for Item in LogItems {
                            LogString += Item.Message
                        }
                        UIPasteboard.general.string = LogString
                    } label: {
                        Label("Copy to clipboard", systemImage: "doc.on.doc")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width - 80, height: 300)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(20)
        .onAppear {
            pipe.fileHandleForReading.readabilityHandler = { fileHandle in
                let data = fileHandle.availableData
                if data.isEmpty  {
                    fileHandle.readabilityHandler = nil
                    sema.signal()
                } else {
                    LogItems.append(LogItem(Message: String(data: data, encoding: .utf8)!))
                }
            }
            setvbuf(stdout, nil, _IONBF, 0)
            dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        }
    }
}

struct LogItem: Identifiable, Equatable {
    var id = UUID()
    var Message: String
}

extension String {
    // If last char is a new line remove it
    func lineFix() -> String {
        return String(self.last == "\n" ? String(self.dropLast()) : self)
    }
}
