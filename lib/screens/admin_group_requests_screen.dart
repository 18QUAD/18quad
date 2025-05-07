import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_scaffold.dart';
import '../services/firestore_service.dart';
import '../providers/user_provider.dart';

class AdminGroupRequestsScreen extends StatefulWidget {
  const AdminGroupRequestsScreen({Key? key}) : super(key: key);

  @override
  State<AdminGroupRequestsScreen> createState() => _AdminGroupRequestsScreenState();
}

class _AdminGroupRequestsScreenState extends State<AdminGroupRequestsScreen> {
  late Future<List<Map<String, dynamic>>> _requestsFuture;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _requestsFuture = _loadRequests();
      _initialized = true;
    }
  }

  Future<List<Map<String, dynamic>>> _loadRequests() async {
    final groupId = context.read<UserProvider>().groupId;
    if (groupId == null) return [];

    return FirestoreService.getGroupRequestsByGroupId(groupId);
  }

  Future<void> _approveRequest(Map<String, dynamic> requestData) async {
    final userId = requestData['userId'];
    final groupId = requestData['groupId'];

    await FirestoreService.updateUser(
      uid: userId,
      groupId: groupId,
    );

    await FirestoreService.updateGroupRequestStatus(
      requesterId: userId,
      groupId: groupId,
      status: 'approved',
    );

    final groupName = await FirestoreService.getGroupName(groupId);
    await FirestoreService.sendNotification(
      toUid: userId,
      message: '$groupName への参加が承認されました',
    );

    setState(() {
      _requestsFuture = _loadRequests();
    });
  }

  Future<void> _rejectRequest(Map<String, dynamic> requestData) async {
    final userId = requestData['userId'];
    final groupId = requestData['groupId'];
    final groupName = await FirestoreService.getGroupName(groupId);

    await FirestoreService.updateGroupRequestStatus(
      requesterId: userId,
      groupId: groupId,
      status: 'rejected',
    );

    await FirestoreService.sendNotification(
      toUid: userId,
      message: '$groupName への参加は却下されました',
    );

    setState(() {
      _requestsFuture = _loadRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'グループリクエスト管理',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }

          final requests = snapshot.data ?? [];
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => _approveRequest(request),
                      child: const Text('承認'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _rejectRequest(request),
                      child: const Text('却下'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
