//
//  UserProfileView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 22/02/2022.
//

import SwiftUI

struct UserProfileView: View {
    @State private var birthdate: Date = .today
    @State private var lovesNotificare: Bool = true
    
    var body: some View {
        NavigationView {
            List {
                VStack(alignment: .center, spacing: 0) {
                    AsyncImageCompat(url: URL(string: "https://gravatar.com/avatar/1a73f51bd2d8f8114835508ecd678c66?s=400&d=blank")) { image in
                        Image(uiImage: image)
                            .resizable()
                    } placeholder: {
                        Color.clear
                    }
                    .frame(width: 128, height: 128)
                    .clipShape(Circle())
                    
                    Text(verbatim: "Helder Pinhal")
                        .font(.title2)
                        .lineLimit(1)
                        .padding(.top)
                    
                    Text(verbatim: "Regular user")
                        .font(.subheadline)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                
                Section {
                    NavigationLink {
                        EmptyView()
                    } label: {
                        Text("Membership card")
                    }
                }
                
                Section {
                    HStack {
                        Text("First name")
                        
                        Spacer()
                        
                        Text("Helder")
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    
                    HStack {
                        Text("Last name")
                        
                        Spacer()
                        
                        Text("Pinhal")
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    
                    DatePicker(
                        "Birthdate",
                        selection: $birthdate,
                        displayedComponents: .date
                    )
                    
                    HStack {
                        Text("Lucky number")
                        
                        Spacer()
                        
                        Text("13")
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    
                    Toggle("Loves Notificare", isOn: $lovesNotificare)
                } header: {
                    Text("Personal information")
                }
                
                Section {
                    Text("Sign out")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
