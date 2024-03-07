//
//  ContentView.swift
//  GitHub SwiftUI
//
//  Created by yucian huang on 2024/2/6.
//

import SwiftUI

struct ContentView: View {
    
    @State private var user: GitHubUser?
    
    
    var body: some View {
        VStack(spacing: 20) {
            
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                
            }  placeholder: {
                
                Circle()
                  .foregroundColor(.secondary)
            }
            .frame(width: 120, height: 120)
              
            Text(user?.login ?? "Login Placeholder")
                .bold()
                .font(.title3)
            
            Text(user?.bio ?? " Bio Placeholder")
                .padding()
                  
            
            Spacer()
        }

        //this give the space outside Vstack
        .padding()
        
        // what is task?
        .task {
            do {
                user = try await getUser()
            } catch GHError.invalidURL {
                print("invalid url")
            } catch GHError.invalidResponse {
                print("invalid response")
            } catch GHError.invalidData {
                print("invalid data")
            } catch {
                print("unexpectd error")
                
            }
        }
    }
    
    // function
    func getUser() async throws -> GitHubUser {
        let endpoint = "https://api.github.com/users/twostraws"
        // twostraws // johnsundell //sallen0400
        
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
        
        // how you downloading your data from url, call ur data
        // we need url object , do unerapping aboved
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidURL
        }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            //if this fails, throw the error enum we created
            throw GHError.invalidURL
        }
                 
    }
}
struct GitHubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String
}
    
enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

#Preview {
    ContentView()
}
