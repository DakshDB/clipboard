import 'package:clipboard/constants/themes.dart';
import 'package:clipboard/controllers/clip_controller.dart';
import 'package:clipboard/controllers/page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/group_controller.dart';

class GroupsContainer extends ConsumerStatefulWidget {
  final double width;

  const GroupsContainer({
    super.key,
    required this.width,
  });

  @override
  ConsumerState<GroupsContainer> createState() => _GroupsContainerState();
}

class _GroupsContainerState extends ConsumerState<GroupsContainer> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(groupProvider.notifier).fetchGroups());
  }

  @override
  Widget build(BuildContext context) {
    final allGroups = ref.watch(groupProvider);
    final groups = _searchQuery.isEmpty
        ? allGroups
        : allGroups.where((group) =>
            group.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            group.description!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Container(
      width: widget.width,
      height: MediaQuery.of(context).size.height * 0.85,
                    margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05),
              padding: const EdgeInsets.fromLTRB(10, 20, 0, 20),
      decoration: BoxDecoration(
        color: platinum,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),child: 
          TextField(
            controller: _searchController,
            style: const TextStyle(color: oxfordBlue),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Search groups',
              labelStyle: TextStyle(color: paynesGray),
              prefixIcon: Icon(Icons.search, color: paynesGray),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: paynesGray),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: teal),
              ),
            ),
          )),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return ListTile(
                  onTap: () {
                    if (group.id == 'all') {
                      ref.read(selectedGroupProvider.notifier).state = null;
                    } else {
                      ref.read(selectedGroupProvider.notifier).state = group;
                    }
                    ref.read(clipProvider.notifier).fetchClips(ref);
                    ref.read(pageControllerProvider.notifier).setPage(1);
                  },
                  title: Text(
                    group.name,
                    style: const TextStyle(color: oxfordBlue, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    group.description ?? '',
                    style: const TextStyle(color: paynesGray),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: paynesGray,
                        onPressed: () {
                          _nameController.text = group.name;
                          _descriptionController.text = group.description ?? '';
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Edit Group', style: TextStyle(color: oxfordBlue)),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: _nameController,
                                    style: const TextStyle(color: oxfordBlue),
                                    decoration: const InputDecoration(
                                      labelText: 'Group Name',
                                      labelStyle: TextStyle(color: paynesGray),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: paynesGray),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: teal),
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    controller: _descriptionController,
                                    style: const TextStyle(color: oxfordBlue),
                                    decoration: const InputDecoration(
                                      labelText: 'Description',
                                      labelStyle: TextStyle(color: paynesGray),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: paynesGray),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: teal),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(foregroundColor: paynesGray),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(groupProvider.notifier)
                                        .updateGroup(
                                          group.id,
                                          _nameController.text,
                                          _descriptionController.text,
                                        );
                                    Navigator.pop(context);
                                  },
                                  style: TextButton.styleFrom(foregroundColor: teal),
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: paynesGray,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Group'),
                              content: const Text(
                                  'Are you sure you want to delete this group?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(groupProvider.notifier)
                                        .deleteGroup(group.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Padding(padding: const EdgeInsets.fromLTRB(10, 0, 20, 0), 
          child: 
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: oxfordBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(40),
            ),
            onPressed: () {
              _nameController.clear();
              _descriptionController.clear();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Create New Group'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: oxfordBlue),
                        decoration: const InputDecoration(
                          labelText: 'Group Name',
                        ),
                      ),
                      TextField(
                        controller: _descriptionController,
                        style: const TextStyle(color: oxfordBlue),
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_nameController.text.isNotEmpty) {
                          ref.read(groupProvider.notifier).addGroup(
                                _nameController.text,
                                _descriptionController.text,
                              );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Create'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Create New Group'),
          ),
        
      )],
      ),
    );
  }
}
