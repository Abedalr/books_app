import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "مركز الإشعارات",
          style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Cairo'),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (user != null)
            IconButton(
              tooltip: "مسح الكل",
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
              onPressed: () => _showDeleteDialog(context, user.uid),
            ),
        ],
      ),
      body: user == null
          ? _buildLoginRequiredState(isDark)
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('receiverId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(isDark);
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final bool isRead = data['isRead'] ?? false;

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) => _deleteNotification(doc.id),
                background: _buildDeleteBackground(),
                child: _buildNotificationItem(context, doc.id, data, isRead, isDark),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, String docId, Map<String, dynamic> data, bool isRead, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead
            ? (isDark ? const Color(0xFF1E293B) : Colors.white)
            : (isDark ? Colors.indigo.withOpacity(0.2) : Colors.blue[50]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRead ? Colors.transparent : Colors.blue.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: isRead
                  ? (isDark ? Colors.grey[800] : Colors.grey[200])
                  : Colors.blueAccent.withOpacity(0.2),
              child: Icon(
                data['type'] == 'reply' ? Icons.forum_rounded : Icons.notifications_active_rounded,
                color: isRead ? Colors.grey : Colors.blueAccent,
                size: 22,
              ),
            ),
            if (!isRead)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  height: 12,
                  width: 12,
                  decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
        title: Text(
          data['senderName'] ?? "تنبيه من مكتبتي",
          style: TextStyle(
            fontWeight: isRead ? FontWeight.w600 : FontWeight.w900,
            fontSize: 15,
            fontFamily: 'Cairo',
            color: isDark ? Colors.white : Colors.blueGrey[900],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              data['message'] ?? "",
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.black87,
                height: 1.4,
                fontFamily: 'Cairo',
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(data['timestamp'] as Timestamp?),
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _handleNotificationClick(context, docId, data),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey[isDark ? 600 : 400]),
          ),
          const SizedBox(height: 20),
          const Text(
            "صندوق الإشعارات فارغ حالياً",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Text(
            "سنخبرك بكل جديد فور حدوثه",
            style: TextStyle(fontSize: 14, fontFamily: 'Cairo', color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRequiredState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded, size: 70, color: Colors.grey[400]),
          const SizedBox(height: 15),
          const Text("يرجى تسجيل الدخول لعرض الإشعارات",
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
    );
  }

  // --- العمليات ---

  void _handleNotificationClick(BuildContext context, String docId, Map<String, dynamic> data) async {
    // تحديث حالة القراءة في Firestore
    await FirebaseFirestore.instance.collection('notifications').doc(docId).update({'isRead': true});

    // منطق التنقل: إذا كان الإشعار رد على مراجعة مثلاً
    // if (data['bookId'] != null) {
    //    انتقل لصفحة الكتاب...
    // }
  }

  void _deleteNotification(String docId) async {
    await FirebaseFirestore.instance.collection('notifications').doc(docId).delete();
  }

  void _showDeleteDialog(BuildContext context, String? userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("مسح الإشعارات", textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Cairo')),
        content: const Text("هل أنت متأكد من مسح جميع الإشعارات؟", textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          TextButton(
            onPressed: () {
              _clearAllNotifications(userId);
              Navigator.pop(context);
            },
            child: const Text("نعم، امسح", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _clearAllNotifications(String? userId) async {
    if (userId == null) return;
    final batch = FirebaseFirestore.instance.batch();
    final querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .get();

    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "الآن";
    DateTime date = timestamp.toDate();
    return DateFormat('dd/MM | hh:mm a').format(date);
  }
}