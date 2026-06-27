// import 'package:flutter/material.dart';
// import 'package:bible/database.dart';
// import '../collections/dict.dart';
// import '../globals.dart';
//
// class DictPage extends StatefulWidget {
//   const DictPage({super.key});
//   @override
//   DictPageState createState() => DictPageState();
// }
//
// class DictPageState extends State<DictPage> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   List<Dict> _results = [];
//   bool _searching = false;
//
//   Future<void> _performSearch() async {
//     final raw = _searchController.text.trim();
//
//     if (raw.isEmpty) {
//       if (!mounted) return;
//       setState(() {
//         _results = [];
//         _searching = false;
//         _searchQuery = '';
//       });
//       return;
//     }
//
//     // Use only the first four letters for the Isar query when the input is 4+ chars
//     final isarQuery = raw.length >= 4 ? raw.substring(0, 4) : raw;
//
//     if (!mounted) return;
//     setState(() {
//       _searching = true;
//       // keep the full query for UI/feedback
//       _searchQuery = raw;
//     });
//
//     try {
//       final results = await isar.dicts
//           .filter()
//           .latStartsWith(isarQuery, caseSensitive: false)
//           .findAll();
//
//       if (!mounted) return;
//       setState(() {
//         _results = results;
//         _searching = false;
//       });
//     } catch (e) {
//       debugPrint('Search error: $e');
//       if (!mounted) return;
//       setState(() {
//         _searching = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(
//           color: Theme.of(context).colorScheme.inversePrimary,
//         ),
//         leading: GestureDetector(
//           child: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               Future.delayed(
//                 Duration(milliseconds: Globals.navigatorDelay),
//                 () {
//                   if (context.mounted) {
//                     Navigator.pop(context);
//                   }
//                 },
//               );
//             },
//           ),
//         ),
//         title: Text(
//           'Dictionary',
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [colorScheme.primary, colorScheme.surface],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Look up...',
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       // subtle tint using the color extension `withValues`
//                       fillColor: colorScheme.surface.withValues(alpha: 0.04),
//                       // outline border + focused/disabled variants
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide(
//                           color: colorScheme.outline,
//                           width: 1,
//                         ),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide(
//                           color: colorScheme.outline,
//                           width: 1,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide(
//                           color: colorScheme.primary,
//                           width: 2,
//                         ),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         vertical: 12.0,
//                       ),
//                     ),
//                     onSubmitted: (_) => _performSearch(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: _searching
//                 ? const Center(child: CircularProgressIndicator())
//                 : _results.isEmpty && _searchQuery.isNotEmpty
//                 ? const Center(child: Text('No results found.'))
//                 : ListView.separated(
//                     itemCount: _results.length,
//                     separatorBuilder: (context, index) => const Divider(),
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         title: Text(
//                           _results[index].lat,
//                           style: TextStyle(
//                             color: colorScheme.primary,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         subtitle: Text(
//                           _results[index].eng,
//                           style: TextStyle(color: colorScheme.secondary),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
