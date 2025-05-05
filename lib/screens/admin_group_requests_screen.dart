import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_scaffold.dart';

class AdminGroupRequestsScreen extends StatefulWidget {
  const AdminGroupRequestsScreen({Key? key}) : super(key: key);

  @override
  State<AdminGroupRequestsScreen> createState() => _AdminGroupRequestsScreenState();
}

class _AdminGroupRequestsScreenState extends State<AdminGroupRequestsScreen> {
  late Future<List<DocumentSnapshot>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestsFuture = FirebaseFirestore.instance
        .collection('groupRequests')
        .orderBy('requestedAt', descending: true)
        .get()
        .then((snapshot) => snapshot.docs);
  }

  Future<void> _approveRequest(DocumentSnapshot requestDoc) async {
    final userId = requestDoc['userId'];
    final groupId = requestDoc['groupId'];

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final requestRef = FirebaseFirestore.instance.collection('groupRequests').doc(requestDoc.id);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(userRef, {'groupId': groupId});
      transaction.delete(requestRef);
    });

    setState(() {
      _requestsFuture = FirebaseFirestore.instance
          .collection('groupRequests')
          .orderBy('requestedAt', descending: true)
          .get()
          .then((snapshot) => snapshot.docs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'グループリクエスト管理',
      child: FutureBuilder<List<DocumentSnapshot>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }

          final requests = snapshot.data!;
          if (requests.isEmpty) {
            return const Center(child: Text('リクエストはありません'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final userId = request['userId'];
              final groupId = request['groupId'];

              return ListTile(
                title: Text('ユーザーID: $userId'),
                subtitle: Text('希望グループID: $groupId'),
                trailing: ElevatedButton(
                  onPressed: () => _approveRequest(request),
                  child: const Text('承認'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
