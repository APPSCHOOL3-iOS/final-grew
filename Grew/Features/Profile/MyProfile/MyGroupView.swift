//
//  MyGroup.swift
//  Grew
//
//  Created by Chloe Chung on 2023/09/22.
//

import SwiftUI

struct MyGroupView: View {
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("My Group View")
            }
        }
    }
}

#Preview {
    NavigationStack {
        MyGroupView()
    }
}
