// SectionHeader(
// icon: Icons.class_,
// title: "Sessions",
// onTap: () {
// // Navigate to sessions or show more
// },
// ),
// SizedBox(
// height: screenHeight * 0.4,
// child: const Sessionw(),
// ),
//
// // Classes section
// SectionHeader(
// icon: Icons.category,
// title: "Classes",
// onTap: () {
// Navigator.push(
// context,
// MaterialPageRoute(
// builder: (context) => const ClassTypeListPage(),
// ),
// );
// },
// ),
// SizedBox(
// height: screenHeight * 0.4,
// child: const Classtype(),
// ),
//
// // Data sections - using reusable component
// DataSection(
// title: "Training Statistics",
// backgroundColor: const Color(0xFF129AA6),
// data: [
// "Total Sessions: 156",
// "Active Members: 89",
// "This Week: 24 sessions",
// "Completion Rate: 94%",
// ],
// ),
//
// DataSection(
// title: "Upcoming Events",
// backgroundColor: Colors.red.shade600,
// data: [
// "Championship - Dec 15",
// "Training Camp - Dec 20",
// "Sparring Session - Dec 22",
// " belt Test - Dec 28",
// ],
// ),
//
// DataSection(
// title: "Recent Achievements",
// backgroundColor: Colors.orange.shade600,
// data: [
// "John Doe - Black Belt",
// "Jane Smith - Tournament Winner",
// "Team Victory - Regional Champs",
// "New Record - 50 Wins",
// ],
// ),