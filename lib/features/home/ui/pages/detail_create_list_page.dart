// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:tawakad_app/core/theme/app_colors.dart';

// import 'package:tawakad_app/core/widgets/field_card.dart'; // ويجتك

// class DetailCreateListPage extends StatelessWidget {
//   const DetailCreateListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF2F2F7), // iOS background
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               /// HEADER
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   /// زر حفظ
//                   CircleAvatar(
//                     radius: 26,
//                     backgroundColor: Colors.blue,
//                     child: const Icon(Icons.check, color: Colors.white),
//                   ),

//                   const Text(
//                     "اسم القائمة",
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   CircleAvatar(
//                     radius: 26,
//                     backgroundColor: Colors.grey.shade300,
//                     child: const Icon(Icons.arrow_forward_ios_rounded),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 20),

//               /// الأغراض
//               const Text(
//                 "الأغراض",
//                 style: TextStyle(color: Colors.grey),
//               ),

//               const SizedBox(height: 8),

//               FieldCard(
//                 children: [
//                   const Divider(),
//                   const Align(
//                     alignment: Alignment.centerLeft,
//                     child: Icon(Icons.add_circle_outline, color: Colors.grey),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 20),

//               /// التاريخ والوقت
//               const Text(
//                 "التاريخ و الوقت",
//                 style: TextStyle(color: Colors.grey),
//               ),

//               const SizedBox(height: 8),

//               FieldCard(
//                 children: [
//                   _switchRow(
//                     title: "التاريخ",
//                     subtitle: "الاثنين، 25 يوليو 2023",
//                     icon: Icons.calendar_today,
//                   ),
//                   const Divider(),
//                   _switchRow(
//                     title: "الوقت",
//                     subtitle: "12:15 ص",
//                     icon: Icons.access_time,
//                   ),
//                   const Divider(),
//                   _switchRow(
//                     title: "التكرار",
//                     subtitle: "كل يوم",
//                     icon: Icons.repeat,
//                     showDays: true,
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 20),

//               /// المشاركة
//               const Text(
//                 "المشاركة",
//                 style: TextStyle(color: Colors.grey),
//               ),

//               const SizedBox(height: 8),

//               FieldCard(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const CircleAvatar(
//                         backgroundColor: Colors.grey,
//                         child: Icon(Icons.person_add, color: Colors.white),
//                       ),
//                       const Text("المشاركة"),
//                       CupertinoSwitch(
//                         value: false,
//                         onChanged: (v) {},
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
