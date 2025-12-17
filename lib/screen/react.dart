import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<Map<String, dynamic>> upcomingFights = [
    {
      "id": 1,
      "fighter1": "Alex Thompson",
      "fighter2": "Mike Rodriguez",
      "weight": "Lightweight",
      "date": "Mar 15, 2024",
      "image":
      "https://images.unsplash.com/photo-1517340073101-289191978ae8?w=900&auto=format&fit=crop&q=60",
    },
    {
      "id": 2,
      "fighter1": "Sarah Martinez",
      "fighter2": "Jessica Lee",
      "weight": "Featherweight",
      "date": "Mar 22, 2024",
      "image":
      "https://images.unsplash.com/photo-1476525223214-c31ff100e1ae?w=900&auto=format&fit=crop&q=60",
    },
  ];

  final List<Map<String, dynamic>> quickStats = [
    {"id": 1, "title": "Active Fighters", "value": "24", "icon": Icons.group},
    {
      "id": 2,
      "title": "Upcoming Events",
      "value": "8",
      "icon": Icons.calendar_month
    },
    {"id": 3, "title": "Recent Wins", "value": "12", "icon": Icons.emoji_events},
    {
      "id": 4,
      "title": "Win Rate",
      "value": "76%",
      "icon": Icons.bar_chart_rounded
    },
  ];

  final List<Map<String, dynamic>> menuItems = [
    {"id": 1, "title": "Fighter Roster", "icon": Icons.group, "route": "/roster"},
    {"id": 2, "title": "Training Programs", "icon": Icons.fitness_center, "route": "/training"},
    {"id": 3, "title": "Fight Schedule", "icon": Icons.calendar_month, "route": "/schedule"},
    {"id": 4, "title": "Statistics", "icon": Icons.bar_chart_rounded, "route": "/stats"},
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),

      // HEADER
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
            color: const Color(0xFF333333),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("FightForge",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 5),
                Text("MMA Management Dashboard",
                    style: TextStyle(color: Color(0xFFCCCCCC))),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // QUICK STATS
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: quickStats.map((stat) {
                        return Container(
                          width: (width / 2) - 24,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF333333),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(stat["icon"], color: Colors.orange, size: 26),
                              const SizedBox(height: 10),
                              Text(stat["value"],
                                  style: const TextStyle(
                                      fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text(stat["title"],
                                  style: const TextStyle(fontSize: 12, color: Color(0xFFCCCCCC))),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // UPCOMING FIGHTS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Upcoming Fights",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Icon(Icons.access_time, color: Colors.orange),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  ...upcomingFights.map((fight) {
                    return GestureDetector(
                      onTap: () => Navigator.pushNamed(context, "/fightDetails"),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF333333),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Image.network(
                                fight["image"],
                                width: width,
                                height: 150,
                                fit: BoxFit.cover,
                                color: Colors.black.withOpacity(0.4),
                                colorBlendMode: BlendMode.darken,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${fight["fighter1"]} vs ${fight["fighter2"]}",
                                      style: const TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(fight["weight"],
                                          style: const TextStyle(color: Colors.orange)),
                                      Text(fight["date"],
                                          style: const TextStyle(color: Color(0xFFCCCCCC))),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 10),

                  // QUICK ACCESS MENU
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Quick Access",
                            style: TextStyle(
                                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),

                        ...menuItems.map((item) {
                          return GestureDetector(
                            onTap: () => Navigator.pushNamed(context, item["route"]),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF333333),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(item["icon"], color: Colors.orange, size: 26),
                                      const SizedBox(width: 12),
                                      Text(item["title"],
                                          style: const TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                  const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
