const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendLikeNotification = functions.firestore
  .document("likes/{likeId}")
  .onCreate(async (snap, context) => {
    try {
      const like = snap.data();
      const postId = like.postId;
      const likerId = like.userId;
      const likeId = context.params.likeId; // Use context to get likeId

      const postDoc = await admin.firestore()
        .collection("post")
        .doc(postId)
        .get();
      if (!postDoc.exists) {
        console.log(`Post not found: ${postId} for like: ${likeId}`);
        return;
      }
      const post = postDoc.data();
      const ownerId = post.userId;

      const likerDoc = await admin.firestore()
        .collection("users")
        .doc(likerId)
        .get();
      if (!likerDoc.exists) {
        console.log(`Liker not found: ${likerId} for like: ${likeId}`);
        return;
      }
      const liker = likerDoc.data();
      const likerUsername = liker.username || "Someone";

      const ownerDoc = await admin.firestore()
        .collection("users")
        .doc(ownerId)
        .get();
      if (!ownerDoc.exists) {
        console.log(`Owner not found: ${ownerId} for like: ${likeId}`);
        return;
      }
      const owner = ownerDoc.data();
      const fcmToken = owner.fcmToken;

      if (!fcmToken) {
        console.log(`No FCM token for user: ${ownerId} for like: ${likeId}`);
        return;
      }

      if (owner && owner.fcmToken === liker.fcmToken) {
        console.log(`Liker and owner are the same user: ${likerId} for like: ${likeId}`);
        return; // Do not send notification if liker is the owner
      }

      const message = {
        notification: {
          title: "New Like!",
          body: `${likerUsername} liked your post!`,
        },
        data: {
          postId: postId,
          type: "like",
        },
        token: fcmToken,
      };

      await admin.messaging().send(message);
      console.log(`Notification sent to: ${ownerId} for like: ${likeId}`);
    } catch (error) {
      console.error(`Error sending notification for like: ${context.params.likeId}:`, error);
    }
  });  
    
    
