import 'package:flutter/material.dart';
import '../../models/child_model.dart';


class ChildListTile extends StatelessWidget {
  final ChildModel child;
  final VoidCallback? onTap;

  const ChildListTile({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    const primaryBlue =
    Color(0xFF0D47A1);

    return InkWell(
      borderRadius: BorderRadius.circular(16),

      onTap:onTap,

      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal:16,
          vertical:14,
        ),

        child:Row(
          children:[
            CircleAvatar(

              radius:24,
              backgroundColor: primaryBlue.withValues(alpha: .1),

              child:Text(
                child.initials,
                style: const TextStyle(
                  color:primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width:14),

            Expanded(
              child:Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children:[
                  Text(
                    child.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:15.5,
                    ),
                  ),

                  const SizedBox(height:4),

                  Text(
                    child.classroom,

                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize:13,
                    ),
                  )
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal:10,
                vertical:5,
              ),

              decoration: BoxDecoration(
                color: child.isPresent ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius:
                BorderRadius.circular(20),
              ),

              child:Text(
                child.isPresent ? "Présent" : "Absent",
                style:
                TextStyle(
                  color: child.isPresent ? Colors.green : Colors.red,
                  fontSize:11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }
}
