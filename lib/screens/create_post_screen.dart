import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // For image picking
import '../models/post.dart';
import '../repositories/post_repository.dart';
import 'dart:io';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  XFile? _selectedImage; // To hold the selected image file
  String? _imageUrl; // To hold the uploaded image URL

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
      
      // Here you would normally upload the image to Firebase Storage
      // For now, we'll just keep the reference to the local file
      // _uploadImage(pickedFile);
    }
  }

  // Placeholder for image upload function
  // Future<void> _uploadImage(XFile imageFile) async {
  //   // TODO: Implement Firebase Storage upload
  //   // This would upload the image and set _imageUrl to the download URL
  // }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final postRepo = Provider.of<PostRepository>(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: () => _submitPost(postRepo, currentUser),
            child: const Text('Post'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Image preview and selection
                if (_selectedImage != null)
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(File(_selectedImage!.path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _removeImage,
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 50),
                          SizedBox(height: 8),
                          Text('Add Image (optional)'),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Title (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'What would you like to share?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some content';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitPost(PostRepository postRepo, User? user) async {
    if (_formKey.currentState!.validate() && user != null) {
      // TODO: Uncomment and implement image upload when Firebase Storage is ready
      // if (_selectedImage != null) {
      //   await _uploadImage(_selectedImage!);
      // }

      final newPost = Post(
        id: '', // Will be generated by Firestore
        authorId: user.uid,
        authorName: user.displayName ?? 'Anonymous',
        authorImage: user.photoURL ?? '',
        title: _titleController.text,
        content: _contentController.text,
        mediaUrls: _selectedImage != null ? [_selectedImage!.path] : [],
        timestamp: DateTime.now(),
      );

      await postRepo.createPost(newPost);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }
}