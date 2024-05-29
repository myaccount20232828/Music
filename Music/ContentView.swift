import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
    @State var Songs: [MusicItem] = []
    @State var Search = ""
    var body: some View {
        ZStack {
            DarkGray
            ScrollView(showsIndicators: false) {
                VStack {
                    Spacer()
                    ForEach(Songs.prefix(20)) { Song in
                        Button {
                            let alert = UIAlertController(title: "Video ID", message: "Put in the YouTube video ID here.", preferredStyle: .alert)
                            alert.addTextField(configurationHandler: { (textField) -> Void in
                                textField.text = UIPasteboard.general.string ?? ""
                                textField.placeholder = "Video ID"
                            })
                            alert.addTextField(configurationHandler: { (textField) -> Void in
                                textField.text = "0"
                                textField.placeholder = "Start Time"
                            })
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (action) -> Void in
                                let Video = ((alert?.textFields![0])! as UITextField).text ?? ""
                                let StartTime = Double(((alert?.textFields![1])! as UITextField).text ?? "0") ?? 0
                                
                            }))
                            UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.present(alert, animated: true)
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
            DispatchQueue.global(qos: .utility).async {
                Songs = SearchSongs(Search)
            }
        }
    }
}

let DarkGray = Color(Hex: "0D1117")
let Gray = Color(Hex: "161B22")
let Gray2 = Color(Hex: "89929B")
let LightGray = Color(Hex: "21262D")
let AppColor = Color(Hex: "7950F2")

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
