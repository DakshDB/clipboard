import 'package:clipboard/controllers/group_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/clip.dart';

class ClipNotifier extends StateNotifier<List<Clip>> {
  ClipNotifier() : super([]);
  
  final CollectionReference _clipsCollection = 
      FirebaseFirestore.instance.collection('clips');
  
  Future<void> fetchClips(ref) async {
    String? groupId; 
    final group = ref.read(selectedGroupProvider.notifier).state;
    if (group!= null) {
      groupId = group.id;
    }
    
    Query query = _clipsCollection.where('deleted_at', isNull: true);
    
    if (groupId != null) {
      query = query.where('group_id', isEqualTo: groupId);
    }
    
    final QuerySnapshot querySnapshot = await query
        .orderBy('created_at', descending: true)
        .get();
    
    final clips = querySnapshot.docs.map((doc) {
      return Clip.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();

    // Filter clips if groupId null
    if (groupId== null) {
      clips.removeWhere((clip) => clip.groupId!= null);
    }

    state = clips;
  }
  
  Future<void> addClip(String content, ref) async {
    String? groupId; 
    final group = ref.read(selectedGroupProvider.notifier).state;
    if (group!= null) {
      groupId = group.id;
    }

    const uuid = Uuid();
    final String tempId = uuid.v4();
    final newClip = Clip(
      id: tempId,
      content: content,
      createdAt: Timestamp.now(),
      groupId: groupId,
    );
    
    // Optimistically update UI
    state = [newClip, ...state];
    
    // Save to Firestore
    final docRef = await _clipsCollection.add(newClip.toFirestore());
    
    // Update state with the real ID
    state = state.map((clip) {
      if (clip.id == tempId) {
        return Clip(
          id: docRef.id,
          content: clip.content,
          createdAt: clip.createdAt,
          deletedAt: clip.deletedAt,
          groupId: clip.groupId,
        );
      }
      return clip;
    }).toList();
  }
  
  Future<void> deleteClip(String id) async {
    // Optimistically update UI
    state = state.where((clip) => clip.id != id).toList();
    
    // Update in Firestore
    await _clipsCollection.doc(id).update({'deleted_at': Timestamp.now()});
  }
}

final clipProvider = StateNotifierProvider<ClipNotifier, List<Clip>>((ref) {
  return ClipNotifier();
});