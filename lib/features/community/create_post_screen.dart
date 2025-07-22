import 'package:flutter/material.dart';
import 'package:haraka_afya_ai/features/community/community_post.dart';
import 'package:haraka_afya_ai/features/community/community_repository.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _category = 'General';
  bool _isEvent = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _submitPost,
            child: const Text(
              'Post',
              style: TextStyle(color: Color(0xFF16A249)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                items: const [
                  DropdownMenuItem(value: 'General', child: Text('General')),
                  DropdownMenuItem(value: 'Diabetes', child: Text('Diabetes')),
                  DropdownMenuItem(
                    value: 'Cancer Survivor', 
                    child: Text('Cancer Survivor'),
                  ),
                ],
                onChanged: (value) => setState(() => _category = value!),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is this an event?'),
                value: _isEvent,
                onChanged: (value) => setState(() => _isEvent = value),
                activeColor: const Color(0xFF16A249),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitPost() {
    if (_formKey.currentState!.validate()) {
      final newPost = CommunityPost(
        id: DateTime.now().toString(),
        authorName: 'Current User', // Replace with actual user
        authorTitle: 'Member', // Replace with actual user title
        title: _titleController.text,
        content: _contentController.text,
        category: _category,
        postedAt: DateTime.now(),
        isEvent: _isEvent,
      );

      CommunityRepository().addPost(newPost);
      Navigator.pop(context);
    }
  }
}