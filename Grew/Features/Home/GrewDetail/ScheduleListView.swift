//
//  ScheduleListView.swift
//  Grew
//
//  Created by KangHo Kim on 2023/10/18.
//

import SwiftUI

struct ScheduleListView: View {
    
    @EnvironmentObject var scheduleStore: ScheduleStore
    let gid: String
    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    @State private var isShowingScheduleSheet: Bool = false
    @State private var isShowingEditSheet: Bool = false
    @State var detentHeight: CGFloat = 0
    
    @State private var selectedSchedule: Schedule?
    
    var body: some View {
        VStack {
            NavigationLink {
                CreateScheduleMainView(gid: gid)
                    .padding(3)
            } label: {
                Text("+ 새 일정 만들기")
            }
            .grewButtonModifier(width: UIScreen.screenWidth - 40, height: 44, buttonColor: .clear, font: .b1_B, fontColor: .DarkGray1, cornerRadius: 8)
            .border(Color.DarkGray1, width: 4)
            .cornerRadius(8)
            Divider()
                .padding(.vertical, 10)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    let schedules = getSchedules()
                    if !schedules.isEmpty {
                        ForEach(0 ..< schedules.count, id: \.self) { index in
                            if let schedule = schedules[safe: index] {
                                ScheduleCellView(index: index, schedule: schedule)
                                    .onTapGesture(perform: {
                                        isShowingEditSheet = false
                                        isShowingScheduleSheet = true
                                    })
                                    .onLongPressGesture {
                                        isShowingScheduleSheet = false
                                        isShowingEditSheet = true
                                    }
                            }
                        }
                    }
                }
            }
        }//: VStack
        .padding(20)
        .sheet(isPresented: $isShowingScheduleSheet, content: {
            ScheduleDetailView(schedule: selectedSchedule)
        })
        .sheet(isPresented: $isShowingEditSheet, content: {
            ScheduleCellEditSheetView()
                .readHeight()
                .onPreferenceChange(HeightPreferenceKey.self) { height in
                    if let height {
                        self.detentHeight = height
                    }
                }
                .presentationDetents([.height(self.detentHeight)])
        })
    }
    func getSchedules() -> [Schedule] {
        
        let schedules = scheduleStore.schedules.filter {
            $0.gid == gid
        }
        return schedules
    }
}

struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat?

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        guard let nextValue = nextValue() else { return }
        value = nextValue
    }
}

private struct ReadHeightModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: HeightPreferenceKey.self, value: geometry.size.height)
        }
    }

    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}

extension View {
    func readHeight() -> some View {
        self
            .modifier(ReadHeightModifier())
    }
}

#Preview {
    ScheduleListView(gid: "")
        .environmentObject(ScheduleStore())
}
