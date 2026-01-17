//
//  TasksPageView.swift
//  HomeHero
//
//  Temporary tasks page placeholder
//

import SwiftUI

struct TasksPageView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.mintCream.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Image(systemName: "checklist")
                        .font(.system(size: 60))
                        .foregroundStyle(AppColor.oxfordNavy)
                    
                    Text("Tasks")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.oxfordNavy)
                    
                    Text("Manage household tasks and chores")
                        .font(.system(size: 17, design: .rounded))
                        .foregroundStyle(AppColor.prussianBlue.opacity(0.70))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: 40)
                    
                    VStack(spacing: 12) {
                        TaskPlaceholderRow(title: "Take out trash", dueDate: "Today")
                        TaskPlaceholderRow(title: "Clean kitchen", dueDate: "Tomorrow")
                        TaskPlaceholderRow(title: "Buy groceries", dueDate: "This week")
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct TaskPlaceholderRow: View {
    let title: String
    let dueDate: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "circle")
                .font(.system(size: 22))
                .foregroundStyle(AppColor.powderBlue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColor.oxfordNavy)
                
                Text(dueDate)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(AppColor.prussianBlue.opacity(0.60))
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    TasksPageView()
}
