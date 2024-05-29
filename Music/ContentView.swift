import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
    @State var Songs: [MusicItem] = []
    @State var Search = ""
    var body: some View {
        ZStack {
            Color("DarkGray")
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
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (action) -> Void in
                                let Video = ((alert?.textFields![0])! as UITextField).text ?? ""
                                
                            }))
                            UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.present(alert, animated: true)
                        } label: {
                            ZStack {
                                Color("Gray")
                                HStack {
                                    if Song.artworkUrl100 == nil {
                                        ZStack {
                                            Color("LightGray")
                                                .frame(width: 67, height: 67)
                                                .cornerRadius(12)
                                            Color("Gray")
                                                .frame(width: 65, height: 65)
                                                .cornerRadius(12)
                                            Color("DarkGray")
                                                .opacity(0.5)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                            Image(systemName: "play")
                                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                .foregroundColor(Color.white)
                                        }
                                    } else {
                                        ZStack {
                                            Color("Gray")
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
                                            .foregroundColor(Color("Gray2"))
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
