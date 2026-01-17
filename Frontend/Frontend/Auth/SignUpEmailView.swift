//
//  SignInEmailView.swift
//  HomeHero
//
//  Created by Antonio conopio on 2025-10-25.
//

import SwiftUI
internal import Combine

@MainActor
final class SignUpEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var firstname = ""
    @Published var lastname = ""
    @Published var phone = ""
    
    func signUp() async throws{
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        try await AuthenticationManager.shared.createUser(
            email: email,
            password: password,
            firstname: firstname,
            lastname: lastname,
            phone: phone)

    }
}

struct SignUpEmailView: View {
    
    @Binding var showSignedInView: Bool
    @StateObject private var viewModel = SignUpEmailViewModel()
    
    var body: some View {
        VStack{
                
            
            Spacer()
            
            HStack{
                TextField("First name...", text: $viewModel.firstname)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                    .autocorrectionDisabled(true)
                
                
                TextField("Last Name...", text: $viewModel.lastname)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                    .autocorrectionDisabled(true)
                    
                    
            }
            
            
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            
            TextField("Phone number...", text: $viewModel.phone)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .keyboardType(.phonePad)
            
            SecureField("Password...", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
            
            Button(action: {
                Task{
                    do{
                        try await viewModel.signUp()
                        print("Succcessfully signed up")
                        showSignedInView = false
                    } catch{
                        print(error)
                    }
                }
            }) {
                Text("Sign up")
                .font(.headline)
                .foregroundColor(.black)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 2)
                )
                .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Sign up")
       
    }
}

#Preview {
    NavigationView{
        SignUpEmailView(showSignedInView: .constant(true))
    }
}
