import 'package:flutter/material.dart';

class ToursPage extends StatefulWidget {
  const ToursPage({super.key});

  @override
  State<ToursPage> createState() => _ToursPageState();
}

class _ToursPageState extends State<ToursPage> {
  final List<Map<String, dynamic>> tours = [
    {
      "title": "Goa Beach Tour",
      "location": "Goa",
      "price": "₹7,999",
      "duration": "4 Days",
      "rating": "4.8",
      "category": "Beach",
      "image":
          "https://images.unsplash.com/photo-1512343879784-a960bf40e7f2"
    },
    {
      "title": "Manali Adventure",
      "location": "Himachal Pradesh",
      "price": "₹12,999",
      "duration": "6 Days",
      "rating": "4.9",
      "category": "Adventure",
      "image":
          "https://images.unsplash.com/photo-1506744038136-46273834b3fb"
    },
    {
      "title": "Ayodhya Darshan",
      "location": "Ayodhya",
      "price": "₹4,999",
      "duration": "2 Days",
      "rating": "4.7",
      "category": "Religious",
      "image":
          "https://images.unsplash.com/photo-1524492412937-b28074a5d7da"
    },
  ];

  String selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    final filteredTours = selectedCategory == "All"
        ? tours
        : tours
            .where(
              (tour) => tour["category"] == selectedCategory,
            )
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        title: const Text("Explore Tours"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner

            Container(
              margin: const EdgeInsets.all(16),
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage(
                    "https://images.unsplash.com/photo-1469854523086-cc02fe5d880",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.3),
                ),
                child: const Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Discover Amazing Places",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Search

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search tours...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Categories

            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  categoryChip("All"),
                  categoryChip("Adventure"),
                  categoryChip("Beach"),
                  categoryChip("Religious"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tour Cards

            ListView.builder(
              itemCount: filteredTours.length,
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final tour = filteredTours[index];

                return TourCard(
                  title: tour["title"],
                  location: tour["location"],
                  price: tour["price"],
                  duration: tour["duration"],
                  rating: tour["rating"],
                  image: tour["image"],
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget categoryChip(String category) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(category),
        selected:
            selectedCategory == category,
        onSelected: (_) {
          setState(() {
            selectedCategory = category;
          });
        },
      ),
    );
  }
}

class TourCard extends StatelessWidget {
  final String title;
  final String location;
  final String price;
  final String duration;
  final String rating;
  final String image;

  const TourCard({
    super.key,
    required this.title,
    required this.location,
    required this.price,
    required this.duration,
    required this.rating,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Image.network(
            image,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: Text(
                        rating,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 18,
                    ),
                    Text(location),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 18,
                    ),
                    Text(duration),
                  ],
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const Spacer(),

                    ElevatedButton(
                      onPressed: () {
                        // Tour Details Page
                      },
                      child:
                          const Text("View Details"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}