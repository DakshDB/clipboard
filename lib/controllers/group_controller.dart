import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/group.dart';

final groupProvider = StateNotifierProvider<GroupController, List<Group>>((ref) {
  return GroupController();
});

final selectedGroupProvider = StateProvider<Group?>((ref) => null);

class GroupController extends StateNotifier<List<Group>> {
  GroupController() : super([]);

  Group? selectedGroup;
  List<Group> _allGroups = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchGroups() async {
    try {
      final snapshot = await _firestore.collection('groups').get();
      var groupsList = snapshot.docs.map((doc) => Group.fromFirestore(doc.id, doc.data())).toList();
      groupsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      // Add a dummy group for "All"
      groupsList.insert(0, Group(id: 'all', name: 'General Clips', description: 'General Clips with no groups assigned', createdAt: Timestamp.now()));
      _allGroups = groupsList;
      state = groupsList;
    } catch (e) {
      print('Error fetching groups: $e');
    }
  }

  Future<void> addGroup(String name, String description) async {
    try {
      final docRef = await _firestore.collection('groups').add({
        'name': name,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });
      final newGroup = Group(
        id: docRef.id,
        name: name,
        description: description,
        createdAt: Timestamp.now(),
      );
      state = [...state, newGroup];
    } catch (e) {
      print('Error adding group: $e');
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await _firestore.collection('groups').doc(groupId).delete();
      state = state.where((group) => group.id != groupId).toList();
    } catch (e) {
      print('Error deleting group: $e');
    }
  }

  Future<void> updateGroup(String groupId, String name, String description) async {
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'name': name,
        'description': description,
      });
      state = state.map((group) => group.id == groupId
          ? group.copyWith(name: name, description: description)
          : group).toList();
    } catch (e) {
      print('Error updating group: $e');
    }
  }
}