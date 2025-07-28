import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalDictionaryPage extends StatefulWidget {
  const MedicalDictionaryPage({super.key});

  @override
  State<MedicalDictionaryPage> createState() => _MedicalDictionaryPageState();
}

class _MedicalDictionaryPageState extends State<MedicalDictionaryPage> {
  String searchQuery = '';
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cancer Medical Dictionary'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search cancer terms...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('medical_dictionary')
                .doc('categories')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              final categories =
                  List<String>.from(snapshot.data!.get('categories'));
              return _buildCategoryFilter(categories);
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('medical_dictionary')
                  .doc('terms')
                  .collection('cancer_terms')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final terms = snapshot.data!.docs.where((doc) {
                  // Filter by category
                  if (selectedCategory != 'All' && 
                      doc['category'] != selectedCategory) {
                    return false;
                  }
                  
                  // Filter by search query
                  if (searchQuery.isNotEmpty) {
                    return doc['term'].toString().toLowerCase().contains(searchQuery) ||
                           doc['definition'].toString().toLowerCase().contains(searchQuery);
                  }
                  
                  return true;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: terms.length,
                  itemBuilder: (context, index) {
                    final term = terms[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  term['term'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(
                                    term['category'],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: Colors.green[50],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              term['definition'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (term['translation'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  term['translation'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(List<String> categories) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip('All'),
          ...categories.map((category) => _buildCategoryChip(category)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = category == selectedCategory;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedCategory = selected ? category : 'All';
          });
        },
        selectedColor: Colors.green[100],
        labelStyle: TextStyle(
          color: isSelected ? Colors.green[800] : Colors.black,
        ),
      ),
    );
  }
}