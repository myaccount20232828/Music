import SwiftUI
import SDWebImageSwiftUI
import Combine

struct AddMusicView: View {
    @State var Songs: [MusicItem] = []
    @State var Search = ""
    @Environment(\.presentationMode) var presentationMode
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
                                    if Result == "Success" {
                                        MusicPlayer.shared.UpdateSongs()
                                    } else {
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
        .navigationBarItems(
            leading:
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    ZStack {
                        Gray
                            .frame(width: 65, height: 25)
                            .cornerRadius(12)
                       Text("Back")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.white)
                    }
                }
            ,
            trailing:
                Color.clear
                .frame(width: 65, height: 25)
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationViewStyle(.stack)
        .searchable(text: $Search)
        .onSubmit(of: .search) {
            DispatchQueue.global(qos: .utility).async {
                Songs = SearchSongs(Search)
            }
        }
        .onChange(of: Search) { _ in
            if Search.isEmpty {
                Songs = []
            }
        }
    }
}

let DarkGray = Color(Hex: "0D1117")
let Gray = Color(Hex: "161B22")
let Gray2 = Color(Hex: "89929B")
let LightGray = Color(Hex: "21262D")
let AppColor = Color(Hex: "339AF0")
