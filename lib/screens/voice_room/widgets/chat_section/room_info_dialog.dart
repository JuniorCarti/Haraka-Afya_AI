import 'package:flutter/material.dart';

class RoomInfoDialog extends StatefulWidget {
  final String roomId;
  final bool isAdmin;
  final Function(String)? onRoomInfoUpdate;
  final Function()? onSwitchToSpeaker;

  const RoomInfoDialog({
    super.key,
    required this.roomId,
    required this.isAdmin,
    this.onRoomInfoUpdate,
    this.onSwitchToSpeaker,
  });

  @override
  State<RoomInfoDialog> createState() => _RoomInfoDialogState();
}

class _RoomInfoDialogState extends State<RoomInfoDialog> with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _welcomeController = TextEditingController();
  late AnimationController _animationController;
  late Animation<Color?> _dialogGradientAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _dialogGradientAnimation = ColorTween(
      begin: const Color(0xFFFF6B6B),
      end: const Color(0xFF4ECDC4),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _welcomeController.dispose();
    super.dispose();
  }

  void _showSwitchToSpeakerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Switch to Speaker Seat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Do you want to switch from host seat to a speaker seat? This will allow you to participate more actively in the conversation while maintaining admin privileges.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSwitchToSpeaker?.call();
              Navigator.pop(context); // Close room info dialog too
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Switch to Speaker'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _dialogGradientAnimation.value!,
                    const Color(0xFF1A1A2E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        const Icon(
                          Icons.settings_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Room Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Settings fields
                    if (widget.isAdmin) ...[
                      _buildTextField(
                        controller: _nameController,
                        label: 'Room Name',
                        hint: 'Enter room name...',
                        icon: Icons.room_preferences_rounded,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _descController,
                        label: 'Description',
                        hint: 'Enter room description...',
                        maxLines: 2,
                        icon: Icons.description_rounded,
                      ),
                      const SizedBox(height: 8),
                    ],
                    _buildTextField(
                      controller: _welcomeController,
                      label: 'Welcome Message',
                      hint: 'Enter welcome message for new users...',
                      maxLines: 2,
                      icon: Icons.waving_hand_rounded,
                    ),
                    
                    // Host options section
                    if (widget.isAdmin && widget.onSwitchToSpeaker != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.swap_horiz, size: 14, color: Colors.blue),
                                SizedBox(width: 6),
                                Text(
                                  'Host Options',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Switch to a speaker seat to participate more actively in conversations.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _showSwitchToSpeakerDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 32),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              child: const Text(
                                'Switch to Speaker Seat',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Info text for non-admins
                    if (!widget.isAdmin)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_rounded,
                              color: _dialogGradientAnimation.value,
                              size: 10,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Only room admins can change room settings',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Action buttons
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white54,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontSize: 11)),
                        ),
                        if (widget.isAdmin)
                          const SizedBox(width: 8),
                        if (widget.isAdmin)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _dialogGradientAnimation.value!,
                                  const Color(0xFF4ECDC4),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextButton(
                              onPressed: () {
                                if (_nameController.text.trim().isNotEmpty) {
                                  widget.onRoomInfoUpdate?.call(_nameController.text.trim());
                                }
                                Navigator.of(context).pop();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              ),
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  icon,
                  size: 12,
                  color: Colors.white70,
                ),
              ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 11),
            maxLines: maxLines,
            maxLength: maxLines == 1 ? 30 : 100,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(8),
              counterText: '',
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}