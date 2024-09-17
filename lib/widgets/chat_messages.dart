import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/widgets/message_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            const Center(
              child: Text('No messages found.'),
            );
          }

          if (chatSnapshot.hasError) {
            const Center(
              child: Text('Something went wrong...'),
            );
          }

          final loadedMessages = chatSnapshot.data!.docs;

          return ListView.builder(
              padding: const EdgeInsets.only(bottom: 40, right: 13, left: 13),
              itemCount: loadedMessages.length,
              reverse: true,
              itemBuilder: (ctx, index) {
                final chatMessage = loadedMessages[index].data();
                final nextChatMessage = index + 1 < loadedMessages.length
                    ? loadedMessages[index + 1].data()
                    : null;

                final currentMessageUid = chatMessage['userId'];
                final nextMessageUid =
                    nextChatMessage != null ? nextChatMessage['userId'] : null;

                final nextUserIsSame = currentMessageUid == nextMessageUid;

                if (nextUserIsSame) {
                  return MessageBubble.next(
                      message: chatMessage['text'],
                      isMe: authenticatedUser.uid == currentMessageUid);
                } else {
                  return MessageBubble.first(
                      username: chatMessage['username'],
                      userImage: chatMessage['userImage'],
                      message: chatMessage['text'],
                      isMe: authenticatedUser.uid == currentMessageUid);
                }
              });
        });
  }
}
