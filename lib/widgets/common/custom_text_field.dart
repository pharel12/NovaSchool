import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {

  // Indique si le mot de passe est masqué
  late bool _hidePassword;

  // Suit l'état de focus pour animer la couleur de l'icône
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _hidePassword = widget.obscureText;

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Colors.orange;
    final Color inactiveColor = Colors.grey.shade500;

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: _hidePassword,
      validator: widget.validator,
      cursorColor: activeColor,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),

      // Validation à chaque modification
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),

        // Icône de gauche : change de couleur selon le focus
        prefixIcon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            widget.icon,
            key: ValueKey(_isFocused),
            color: _isFocused ? activeColor : inactiveColor,
            size: 18,
          ),
        ),

        // Icône pour afficher/masquer le mot de passe
        suffixIcon: widget.obscureText
            ? IconButton(
          splashRadius: 20,
          icon: Icon(
            _hidePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: inactiveColor,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _hidePassword = !_hidePassword;
            });
          },
        )
            : null,

        filled: true,
        fillColor: const Color(0xFFF4F4F4),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),

        // Style du texte d'erreur
        errorStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 0.8,
        ),
        errorMaxLines: 2,

        // Bordure normale (léger contour au repos)
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),

        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.orange,
            width: 2,
          ),
        ),

        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.redAccent,
            width: 1.5,
          ),
        ),

        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.redAccent,
            width: 2,
          ),
        ),
      ),
    );
  }
}