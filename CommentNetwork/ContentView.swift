//
//  ContentView.swift
//  CommentNetwork
//
//  Created by Isuru Ariyarathna on 2024-10-16.
//

import SwiftUI

struct UserDTO : Codable, Hashable {
    let id: Int
    let username: String
    let fullName: String
}

struct DataDTO : Codable, Hashable {
    let commentId: Int
    let postId: Int
    let body: String
    let likes: Int
    let user : UserDTO
    
    enum CodingKeys: String, CodingKey {
        case commentId = "id"
        case postId
        case likes
        case body
        case user
    }
}

struct ContentView: View {
    @State var commentData : DataDTO?
    @State var isLoading : Bool = true
    
    var body: some View {
        NavigationStack {
            VStack (alignment: .leading) {
                if isLoading {
                    ProgressView()
                } else {
                    VStack (alignment: .leading) {
                        Text("\(commentData?.user.username ?? "")")
                            .font(.title)
                        Text("\(commentData?.body ?? "")")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
            .navigationTitle("Comment")
        }
        .onAppear{
            Task{
                await fetchComment()
            }
        }
        .refreshable {
            Task{
                await fetchComment()
            }
        }
    }
    
    func fetchComment() async {
        let url = URL(string: "https://dummyjson.com/comments/1")
        
        guard let unwrappedUrl = url else { return }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: unwrappedUrl)
            
            guard let response = response as? HTTPURLResponse else {
                print("Something went wrong")
                return
            }
            
            switch response.statusCode {
                case 200...300:
                    let commentData = try JSONDecoder().decode(DataDTO.self, from: data)
                    self.commentData = commentData
                case 400...500:
                    print("Server error")
                default:
                    print("Unknown error")
            }
        } catch {
            print("Error fetching data: \(error)")
        }
        self.isLoading = false
    }
}

#Preview {
    ContentView()
}
