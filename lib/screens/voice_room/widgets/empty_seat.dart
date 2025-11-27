import 'package:flutter/material.dart';

class EmptySeat extends StatelessWidget {
  final int seatNumber;
  final VoidCallback onTap;
  final VoidCallback? onSwitchSeat;
  final bool canSwitch;
  final bool isHostSeat;

  const EmptySeat({
    super.key, 
    required this.seatNumber, 
    required this.onTap,
    this.onSwitchSeat,
    this.canSwitch = false,
    this.isHostSeat = false,
  });

  @override
  Widget build(BuildContext context) {
    final seatColor = isHostSeat ? Colors.amber : Colors.green;
    
    return Container(
      margin: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Seat Circle with custom icon
          GestureDetector(
            onTap: onTap,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: seatColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Pulsing animation effect
                    if (!isHostSeat)
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: seatColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    
                    // Host crown border for seat 0
                    if (isHostSeat)
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    
                    // Custom seat icon
                    Center(
                      child: _buildCustomSeatIcon(seatColor),
                    ),
                    
                    // Hover effect layer
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(35),
                          onTap: onTap,
                          child: Container(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 6),
          
          // Seat information
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isHostSeat ? 'Host Seat' : 'Seat $seatNumber',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              
              // Available badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: seatColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: seatColor.withOpacity(0.4),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  'AVAILABLE',
                  style: TextStyle(
                    color: seatColor.withOpacity(0.9),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              
              // Switch button (only shown if user has a seat and this isn't host seat)
              if (canSwitch && onSwitchSeat != null && !isHostSeat) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onSwitchSeat,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.4),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.swap_horiz_rounded,
                            color: Colors.blue.withOpacity(0.9),
                            size: 10,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'SWITCH',
                            style: TextStyle(
                              color: Colors.blue.withOpacity(0.9),
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              
              // Host seat indicator
              if (isHostSeat) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Colors.amber.withOpacity(0.8),
                        size: 8,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'HOST',
                        style: TextStyle(
                          color: Colors.amber.withOpacity(0.8),
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Custom seat icon builder
  Widget _buildCustomSeatIcon(Color color) {
    return Image.asset(
      'assets/images/seat_icon.png',
      width: isHostSeat ? 28 : 24,
      height: isHostSeat ? 28 : 24,
      color: color.withOpacity(0.6),
      errorBuilder: (context, error, stackTrace) {
        // Fallback to Material icon if custom icon not found
        return Icon(
          isHostSeat ? Icons.king_bed_rounded : Icons.event_seat_outlined,
          color: color.withOpacity(0.6),
          size: isHostSeat ? 26 : 22,
        );
      },
    );
  }
}

// Enhanced Empty Seat with Tooltip and Better Animations
class EnhancedEmptySeat extends StatefulWidget {
  final int seatNumber;
  final VoidCallback onJoinSeat;
  final VoidCallback? onSwitchSeat;
  final bool canSwitch;
  final bool isHostSeat;
  final String? tooltipMessage;

  const EnhancedEmptySeat({
    super.key, 
    required this.seatNumber, 
    required this.onJoinSeat,
    this.onSwitchSeat,
    this.canSwitch = false,
    this.isHostSeat = false,
    this.tooltipMessage,
  });

  @override
  State<EnhancedEmptySeat> createState() => _EnhancedEmptySeatState();
}

class _EnhancedEmptySeatState extends State<EnhancedEmptySeat> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Color?> _borderColorAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    final seatColor = widget.isHostSeat ? Colors.amber : Colors.green;
    _borderColorAnimation = ColorTween(
      begin: seatColor.withOpacity(0.3),
      end: seatColor.withOpacity(0.6),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seatColor = widget.isHostSeat ? Colors.amber : Colors.green;
    final canJoin = !widget.isHostSeat || (widget.isHostSeat && widget.canSwitch);
    
    return Tooltip(
      message: widget.tooltipMessage ?? 
          (widget.isHostSeat 
              ? (canJoin ? 'Join as Host' : 'Host seat - Only for room creator')
              : (widget.canSwitch ? 'Click to join or switch to this seat' : 'Click to join this seat')),
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Seat Circle with Custom Icon
            MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: GestureDetector(
                onTap: canJoin ? widget.onJoinSeat : null,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isHovered && canJoin ? _scaleAnimation.value : 1.0,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(_isHovered && canJoin ? 0.12 : 0.08),
                              Colors.white.withOpacity(_isHovered && canJoin ? 0.04 : 0.02),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: _isHovered && canJoin 
                                ? seatColor.withOpacity(0.5) 
                                : _borderColorAnimation.value!,
                            width: _isHovered && canJoin ? 2.0 : 1.5,
                          ),
                          boxShadow: _isHovered && canJoin ? [
                            BoxShadow(
                              color: seatColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ] : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Pulsing border animation
                            if (!widget.isHostSeat && canJoin)
                            Positioned.fill(
                              child: Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: seatColor.withOpacity(_opacityAnimation.value),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Host crown border
                            if (widget.isHostSeat)
                            Positioned.fill(
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.amber.withOpacity(_isHovered && canJoin ? 0.7 : 0.5),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Custom seat icon
                            Center(
                              child: _buildEnhancedCustomSeatIcon(seatColor, canJoin),
                            ),
                            
                            // Disabled overlay
                            if (!canJoin)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.lock_rounded,
                                    color: Colors.white.withOpacity(0.5),
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Hover effect
                            if (canJoin)
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(35),
                                  onTap: widget.onJoinSeat,
                                  hoverColor: seatColor.withOpacity(0.1),
                                  splashColor: seatColor.withOpacity(0.2),
                                  child: Container(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 6),
            
            // Seat information with enhanced layout
            _buildSeatInfo(seatColor, canJoin),
          ],
        ),
      ),
    );
  }

  // Enhanced custom seat icon with hover effects
  Widget _buildEnhancedCustomSeatIcon(Color color, bool canJoin) {
    final iconOpacity = canJoin ? (_isHovered ? 0.8 : 0.6) : 0.3;
    final iconSize = widget.isHostSeat ? 28 : 24;
return Image.asset(
  'assets/images/seat_icon.png',
  width: iconSize * 1.0, // Convert to double
  height: iconSize * 1.0, // Convert to double
  color: color.withOpacity(iconOpacity),
  errorBuilder: (context, error, stackTrace) {
    // Fallback to Material icons if custom icon not found
    return Icon(
      widget.isHostSeat ? Icons.king_bed_rounded : Icons.event_seat_outlined,
      color: color.withOpacity(iconOpacity),
      size: widget.isHostSeat ? 26 : 22,
    );
  },
);
  
  }

  Widget _buildSeatInfo(Color seatColor, bool canJoin) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Seat title
        Text(
          widget.isHostSeat ? 'Host Seat' : 'Seat ${widget.seatNumber}',
          style: TextStyle(
            color: canJoin ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.4),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: canJoin ? seatColor.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: canJoin ? seatColor.withOpacity(0.4) : Colors.grey.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Text(
            canJoin ? 'AVAILABLE' : 'RESTRICTED',
            style: TextStyle(
              color: canJoin ? seatColor.withOpacity(0.9) : Colors.grey.withOpacity(0.7),
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        
        // Action buttons
        if (canJoin) ...[
          const SizedBox(height: 4),
          
          // Join button
          GestureDetector(
            onTap: widget.onJoinSeat,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: seatColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: seatColor.withOpacity(0.5),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_rounded,
                      color: seatColor.withOpacity(0.9),
                      size: 10,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'JOIN',
                      style: TextStyle(
                        color: seatColor.withOpacity(0.9),
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Switch button (only if user already has a seat)
          if (widget.canSwitch && widget.onSwitchSeat != null && !widget.isHostSeat) ...[
            const SizedBox(height: 2),
            GestureDetector(
              onTap: widget.onSwitchSeat,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.4),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swap_horiz_rounded,
                        color: Colors.blue.withOpacity(0.9),
                        size: 10,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'SWITCH',
                        style: TextStyle(
                          color: Colors.blue.withOpacity(0.9),
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
        
        // Host indicator
        if (widget.isHostSeat) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: Colors.amber.withOpacity(0.8),
                  size: 8,
                ),
                const SizedBox(width: 2),
                Text(
                  'HOST',
                  style: TextStyle(
                    color: Colors.amber.withOpacity(0.8),
                    fontSize: 6,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}