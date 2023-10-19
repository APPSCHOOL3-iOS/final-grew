//
//  ChatDetailView.swift
//  ChatTestProject
//
//  Created by daye on 2023/09/24.
//

import FirebaseAuth
import FirebaseStorage
import SwiftUI

struct ChatDetailView: View {
    // 채팅방 데이터
    let chatRoom: ChatRoom
    // 나를 제외한 유저 목록
    let targetUserInfos: [User]
    
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var chatStore: ChatStore
    @EnvironmentObject private var messageStore: MessageStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var groupDetailConfig = GroupDetailConfig()
    @State private var unreadMessageIndex: Int?
    @State private var isMenuOpen: Bool = false
    @State private var isExitButtonAlert = false
    @State private var x = UIScreen.main.bounds.width
    let width = UIScreen.main.bounds.width
    
    var body: some View {
        VStack {
            // 채팅
            ChatMessageListView(chatRoom: chatRoom,
                                targetUserInfos: targetUserInfos,
                                isMenuOpen: $isMenuOpen,
                                x: $x,
                                unreadMessageIndex: $unreadMessageIndex
            )
            //            .zIndex(1)
            
            // 채팅 입력창
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    if groupDetailConfig.selectedImage != nil {
                        HStack {
                            Spacer()
                        }
                    }
                    ChatInputView(chatRoom: chatRoom, groupDetailConfig: $groupDetailConfig)
                        .background(Color(.systemBackground).ignoresSafeArea())
                        .shadow(radius: 0.5)
                        .position(x: geometry.size.width / 2, y: geometry.size.height-30)
                }
            }
            //            .zIndex(2)
            
            // 사이드 메뉴 바
            if isMenuOpen {
                SideBarShadowView(isMenuOpen: $isMenuOpen)
                //                    .zIndex(3)
                ChatSideBar(isMenuOpen: $isMenuOpen, isExitButtonAlert: $isExitButtonAlert)
                    .offset(x: x)
                    .transition(isMenuOpen == true ? .move(edge: .trailing) : .identity)
                    .gesture(DragGesture().onChanged({ (value) in
                        withAnimation(.easeInOut){
                            if value.translation.width < 0 {
                                x = width + value.translation.width
                            } else {
                                x = value.translation.width
                            }
                        }
                    }).onEnded({ (value) in
                        withAnimation(.easeInOut) {
                            if x < width / 2 {
                                x = 0
                            } else {
                                x = width
                                isMenuOpen = false
                            }
                        }
                    }))
                //                    .zIndex(4)
            }
        }
        .alert("채팅방 나가기", isPresented: $isExitButtonAlert) {
            Button("취소", role: .cancel) {}
            Button("확인", role: .destructive) {
                isMenuOpen = false
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("채팅 내역이 모두 삭제됩니다.")
        }
        .confirmationDialog("Options", isPresented: $groupDetailConfig.showOptions, actions: {
            Button("Camera") {
                groupDetailConfig.sourceType = .camera
            }
            Button("Photo Library") {
                groupDetailConfig.sourceType = .photoLibrary
            }
        })
        .sheet(item: $groupDetailConfig.sourceType, content: { sourceType in
            ChatImagePicker(image: $groupDetailConfig.selectedImage, sourceType: sourceType)
        })
        .task {
            let unreadMessageCount = await getUnReadCount()
            messageStore.addListener(chatRoomID: chatRoom.id)
            await messageStore.fetchMessages(chatID: chatRoom.id, unreadMessageCount: unreadMessageCount)
            unreadMessageIndex = messageStore.messages.count - unreadMessageCount
        }
    }
    
    private func getUnReadCount() async -> Int {
        let dict = await chatStore.getUnreadMessageDictionary(chatRoomID: chatRoom.id)
        let unreadCount = dict?[UserStore.shared.currentUser!.id! ] ?? 0
        return unreadCount
    }
}
