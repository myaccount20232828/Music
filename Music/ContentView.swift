import SwiftUI

struct ContentView: View {
    @State var Songs: [MusicItem] = []
    @State var Search = ""
    var body: some View {
        NavigationView {
            Form {
                ForEach(Songs) { Song in
                    Text(Song.trackName)
                }
            }
            .searchable(text: $Search)
        }
        .navigationViewStyle(.stack)
        .onChange(of: Search) { _ in
            DispatchQueue.global(qos: .utility).async {
                Songs = SearchSongs(Search)
            }
        }
    }
}
