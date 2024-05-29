import SwiftUI
import SDWebImageSwiftUI
import Combine

struct ContentView: View {
    @State var Songs: [MusicItem] = []
    @State var Search = ""
    @State var DebounceCancellable: AnyCancellable? = nil
    var body: some View {
        ZStack {
            DarkGray
               .edgesIgnoringSafeArea(.all)
            ScrollView(showsIndicators: false) {
                VStack {
                    Spacer()
                    ForEach(Songs.sorted(by: {$0.trackName.levenshteinDistanceScore(to: Search) > $1.trackName.levenshteinDistanceScore(to: Search)})) { Song in
                        Button {
                            let Alert = UIAlertController(title: "Video ID", message: "Put in the YouTube Video ID here.", preferredStyle: .alert)
                            Alert.addTextField(configurationHandler: { (TextField) -> Void in
                                TextField.text = GetVideoID(UIPasteboard.general.string ?? "")
                                TextField.placeholder = "Video ID"
                            })
                            Alert.addTextField(configurationHandler: { (TextField) -> Void in
                                TextField.text = "0"
                                TextField.placeholder = "Start Time"
                                TextField.keyboardType = .numberPad
                            })
                            Alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            Alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak Alert] (action) -> Void in
                                let Video = GetVideoID(((Alert?.textFields![0])! as UITextField).text ?? "")
                                let StartTime = Double(((Alert?.textFields![1])! as UITextField).text ?? "0") ?? 0
                                DispatchQueue.global(qos: .utility).async {
                                    ShowAlert(UIAlertController(title: "Creating \(Song.trackName)", message: "", preferredStyle: .alert))
                                    let Result = MakeSong(Song, Video, StartTime)
                                    if Result != "Success" {
                                        Thread.sleep(forTimeInterval: 0.3)
                                    }
                                    Dismiss()
                                    ShowAlert(UIAlertController(title: Result == "Success" ? "Added \(Song.trackName)" : "Failed!", message: Result == "Success" ? "" : Result, preferredStyle: .alert))
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        Dismiss()
                                    }
                                }
                            }))
                            ShowAlert(Alert)
                        } label: {
                            ZStack {
                                Gray
                                HStack {
                                    if Song.artworkUrl100 == nil {
                                        ZStack {
                                            LightGray
                                                .frame(width: 67, height: 67)
                                                .cornerRadius(12)
                                            Gray
                                                .frame(width: 65, height: 65)
                                                .cornerRadius(12)
                                            DarkGray
                                                .opacity(0.5)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                            Image(systemName: "play")
                                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                .foregroundColor(Color.white)
                                        }
                                    } else {
                                        ZStack {
                                            Gray
                                                .frame(width: 67, height: 67)
                                                .cornerRadius(12)
                                            WebImage(url: URL(string: Song.artworkUrl100))
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 67, height: 67)
                                                .cornerRadius(12)
                                        }
                                    }
                                    VStack(alignment: .leading) {
                                        Text(Song.trackName)
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .lineLimit(2)
                                        Text(Song.artistName)
                                            .foregroundColor(Gray2)
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .lineLimit(1)
                                    }
                                    .padding(.horizontal, 14)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .offset(x: 10)
                            }
                            .frame(width: UIScreen.main.bounds.width - 25, height: 87)
                            .cornerRadius(16)
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                } 
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Search")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .searchable(text: $Search)
        .onChange(of: Search) { _ in
            DebounceCancellable?.cancel()
            if Search.isEmpty {
                Songs = []
            } else {
                DebounceCancellable = Just(Search)
                .delay(for: .milliseconds(400), scheduler: RunLoop.main)
                .sink { _ in
                    DispatchQueue.global(qos: .utility).async {
                        let NewSongs = SearchSongs(Search)
                        Songs = NewSongs
                    }
                }
            }
        }
    }
}

let DarkGray = Color(Hex: "0D1117")
let Gray = Color(Hex: "161B22")
let Gray2 = Color(Hex: "89929B")
let LightGray = Color(Hex: "21262D")
let AppColor = Color(Hex: "7950F2")

func ShowAlert(_ Alert: UIAlertController) {
    DispatchQueue.main.async {
        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.present(Alert, animated: true)
    }
}

func Dismiss() {
    DispatchQueue.main.async {
        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.dismiss(animated: true)
    }
}

func GetVideoID(_ Video: String) -> String {
    if Video.contains("youtu.be") {
        return Video.components(separatedBy: "youtu.be/")[1].components(separatedBy: "?")[0]
    } else {
        return Video
    }
}

extension Color {
    init(Hex: String, Opacity: CGFloat = 1.0) {
        let Hex = Hex.replacingOccurrences(of: "#", with: "")
        if Hex.count == 6, let Red = Int(Hex.prefix(2), radix: 16), let Green = Int(Hex.prefix(4).suffix(2), radix: 16), let Blue = Int(Hex.suffix(2), radix: 16) {
            self = Color(UIColor.init(red: CGFloat(Red) / 255, green: CGFloat(Green) / 255, blue: CGFloat(Blue) / 255, alpha: Opacity))
        } else {
            self = .clear
        }
    }
}

extension String {
    func levenshteinDistanceScore(to string: String, ignoreCase: Bool = true, trimWhiteSpacesAndNewLines: Bool = true) -> Double {
        var firstString = self
        var secondString = string
        if ignoreCase {
            firstString = firstString.lowercased()
            secondString = secondString.lowercased()
        }
        if trimWhiteSpacesAndNewLines {
            firstString = firstString.trimmingCharacters(in: .whitespacesAndNewlines)
            secondString = secondString.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let empty = [Int](repeating:0, count: secondString.count)
        var last = [Int](0...secondString.count)
        for (i, tLett) in firstString.enumerated() {
            var cur = [i + 1] + empty
            for (j, sLett) in secondString.enumerated() {
                cur[j + 1] = tLett == sLett ? last[j] : Swift.min(last[j], last[j + 1], cur[j])+1
            }
            last = cur
        }
        // maximum string length between the two
        let lowestScore = max(firstString.count, secondString.count)
        if let validDistance = last.last {
            return  1 - (Double(validDistance) / Double(lowestScore))
        }
        return 0.0
    }
}
