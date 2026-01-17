//
//  AuthView.swift
//  HomeHero
//
//  Created by Antonio conopio on 2025-10-25.
//

import SwiftUI

struct AuthView: View {
    
    @Binding var showSignedInView: Bool
    var body: some View {
        VStack {
            Text("Welcome to HomeHero")
                .font(.largeTitle)
                .fontWeight(.bold)
                
            
            Spacer()
            
            NavigationLink{
                SignInEmailView(showSignedInView: $showSignedInView)
            }label:{
                HStack{
                    Image(systemName: "envelope")
                    Text("Continue With Email")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(height:55)
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(10)
            }
            
            
            HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)

                        Text("OR")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)

                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
            
            NavigationLink{
                Text("HELLO")
            }
            label:{
                HStack{
                    Image(systemName: "envelope")
                    Text("Continue With Google")
                        .font(.headline)
                }
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
            
        }
        .padding()
        
        
    }
}

#Preview {
    NavigationView{
        AuthView(showSignedInView: .constant(true))
    }
}
