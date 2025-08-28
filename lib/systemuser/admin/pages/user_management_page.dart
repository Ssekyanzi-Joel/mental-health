// lib/screens/admin/user_management_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final CollectionReference<Map<String, dynamic>> usersRef =
      FirebaseFirestore.instance.collection('users').withConverter<Map<String, dynamic>>(
            fromFirestore: (snap, _) => snap.data()!,
            toFirestore: (value, _) => value,
          );

  final TextEditingController _searchCtrl = TextEditingController();
  String _roleFilter = 'All';
  bool _isLoadingRole = true;
  String _currentUserRole = 'User';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserRole();
  }

  Future<void> _loadCurrentUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _currentUserRole = 'User';
        _isLoadingRole = false;
      });
      return;
    }

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    setState(() {
      _currentUserRole = (data != null && data['role'] != null) ? data['role'] as String : 'User';
      _isLoadingRole = false;
    });
  }

  bool get _canEdit => _currentUserRole == 'Admin' || _currentUserRole == 'Therapist';

  // Opens create or update modal. If id == null => create, else update.
  Future<void> _openUserForm({String? id, Map<String, dynamic>? existing}) async {
    final formKey = GlobalKey<FormState>();
    final firstNameCtrl = TextEditingController(text: existing?['firstName'] ?? '');
    final lastNameCtrl = TextEditingController(text: existing?['lastName'] ?? '');
    final emailCtrl = TextEditingController(text: existing?['email'] ?? '');
    final phoneCtrl = TextEditingController(text: existing?['phone'] ?? '');
    final genderCtrl = TextEditingController(text: existing?['gender'] ?? '');
    final cityCtrl = TextEditingController(text: existing?['city'] ?? '');
    final countryCtrl = TextEditingController(text: existing?['country'] ?? '');
    String roleValue = existing?['role'] ?? 'User';

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(id == null ? 'Create User' : 'Update User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Row(children: [
                        Expanded(child: _buildTextField(firstNameCtrl, 'First name')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTextField(lastNameCtrl, 'Last name')),
                      ]),
                      const SizedBox(height: 8),
                      _buildTextField(emailCtrl, 'Email', keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: _buildTextField(cityCtrl, 'City')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTextField(countryCtrl, 'Country')),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: _buildTextField(phoneCtrl, 'Phone', keyboardType: TextInputType.phone)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: roleValue,
                            decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 'User', child: Text('User')),
                              DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                              DropdownMenuItem(value: 'Therapist', child: Text('Therapist')),
                            ],
                            onChanged: (v) => roleValue = v ?? roleValue,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      _buildTextField(genderCtrl, 'Gender'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                              child: const Text('Cancel')),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;

                                final payload = {
                                  'firstName': firstNameCtrl.text.trim(),
                                  'lastName': lastNameCtrl.text.trim(),
                                  'email': emailCtrl.text.trim(),
                                  'phone': phoneCtrl.text.trim(),
                                  'gender': genderCtrl.text.trim(),
                                  'city': cityCtrl.text.trim(),
                                  'country': countryCtrl.text.trim(),
                                  'role': roleValue,
                                  'createdAt': FieldValue.serverTimestamp(),
                                };

                                try {
                                  if (id == null) {
                                    await usersRef.add(payload);
                                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User created')));
                                  } else {
                                    await usersRef.doc(id).update(payload);
                                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User updated')));
                                  }
                                  Navigator.pop(ctx);
                                } catch (e) {
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                                }
                              },
                              child: Text(id == null ? 'Create' : 'Update'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: (v) {
        if ((v ?? '').trim().isEmpty) return '$label is required';
        if (label == 'Email' && !RegExp(r'\S+@\S+\.\S+').hasMatch(v!.trim())) return 'Enter a valid email';
        return null;
      },
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }

  Future<void> _confirmDelete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete user?'),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await usersRef.doc(id).delete();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted')));
    }
  }

  void _showDetails(Map<String, dynamic> data) {
    final createdAt = data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate() : null;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rowDetail('Email', data['email']),
            _rowDetail('Phone', data['phone']),
            _rowDetail('Gender', data['gender']),
            _rowDetail('City', data['city']),
            _rowDetail('Country', data['country']),
            _rowDetail('Role', data['role']),
            if (createdAt != null) _rowDetail('Created', DateFormat.yMMMd().add_jm().format(createdAt)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Widget _rowDetail(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value?.toString() ?? '-')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterDocs(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final term = _searchCtrl.text.trim().toLowerCase();
    final roleFilter = _roleFilter;
    return docs.map((d) {
      final m = d.data();
      final map = <String, dynamic>{...m, '_id': d.id};
      return map;
    }).where((map) {
      if (roleFilter != 'All' && (map['role'] ?? 'User') != roleFilter) return false;
      if (term.isEmpty) return true;
      final combined = '${map['firstName'] ?? ''} ${map['lastName'] ?? ''} ${map['email'] ?? ''} ${map['phone'] ?? ''}'.toLowerCase();
      return combined.contains(term);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          if (_isLoadingRole)
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))),
          if (!_isLoadingRole && _canEdit)
            IconButton(
              tooltip: 'Create user',
              onPressed: () => _openUserForm(),
              icon: const Icon(Icons.person_add),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search & filter bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search name, email or phone', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _roleFilter,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'Therapist', child: Text('Therapist')),
                  DropdownMenuItem(value: 'User', child: Text('User')),
                ],
                onChanged: (v) => setState(() => _roleFilter = v ?? 'All'),
              ),
            ]),
          ),

          // Stream list
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: usersRef.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                final filtered = _filterDocs(docs);

                if (filtered.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final map = filtered[index];
                    final id = map['_id'] as String;
                    // Removed unused 'createdAt' variable

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(child: Text((map['firstName'] ?? 'U').toString().substring(0, 1).toUpperCase())),
                      title: Text('${map['firstName'] ?? ''} ${map['lastName'] ?? ''}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(map['email'] ?? ''),
                          const SizedBox(height: 4),
                          Text('${map['phone'] ?? ''} • ${map['city'] ?? ''}, ${map['country'] ?? ''}'),
                        ],
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(icon: const Icon(Icons.visibility), tooltip: 'View', onPressed: () => _showDetails(map)),
                          if (_canEdit) IconButton(icon: const Icon(Icons.edit, color: Colors.blue), tooltip: 'Edit', onPressed: () => _openUserForm(id: id, existing: map)),
                          if (_canEdit) IconButton(icon: const Icon(Icons.delete, color: Colors.red), tooltip: 'Delete', onPressed: () => _confirmDelete(id)),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () => _showDetails(map),
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
}
