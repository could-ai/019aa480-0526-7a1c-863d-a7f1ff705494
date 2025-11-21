import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TikTok Style Gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.pinkAccent,
          secondary: Colors.white,
        ),
      ),
      home: const GalleryHomeScreen(),
    );
  }
}

// Model Data Sederhana
class MediaItem {
  final String id;
  final String type; // 'image' or 'video'
  final String url;
  final String username;
  final String description;

  MediaItem({
    required this.id,
    required this.type,
    required this.url,
    required this.username,
    required this.description,
  });
}

class GalleryHomeScreen extends StatefulWidget {
  const GalleryHomeScreen({super.key});

  @override
  State<GalleryHomeScreen> createState() => _GalleryHomeScreenState();
}

class _GalleryHomeScreenState extends State<GalleryHomeScreen> {
  // Filter aktif: 'all', 'image', 'video'
  String _currentFilter = 'all';
  final PageController _pageController = PageController();

  // Dummy Data
  final List<MediaItem> _allMedia = [
    MediaItem(
      id: '1',
      type: 'image',
      url: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      username: '@nature_lover',
      description: 'Pemandangan indah pegunungan di pagi hari 🏔️ #nature #view',
    ),
    MediaItem(
      id: '2',
      type: 'video',
      url: 'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      username: '@travel_vlog',
      description: 'Perjalanan menuju puncak! Klik untuk menonton video lengkapnya 🎥',
    ),
    MediaItem(
      id: '3',
      type: 'image',
      url: 'https://images.unsplash.com/photo-1517849845537-4d257902454a?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      username: '@doggo_daily',
      description: 'Anjing lucu sedang bermain di taman 🐶',
    ),
    MediaItem(
      id: '4',
      type: 'video',
      url: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      username: '@tech_guru',
      description: 'Review kamera terbaru, hasilnya tajam banget! 📸',
    ),
    MediaItem(
      id: '5',
      type: 'image',
      url: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      username: '@forest_life',
      description: 'Suasana hutan yang menenangkan jiwa 🌲',
    ),
  ];

  // Mendapatkan list berdasarkan filter
  List<MediaItem> get _filteredMedia {
    if (_currentFilter == 'all') {
      return _allMedia;
    }
    return _allMedia.where((item) => item.type == _currentFilter).toList();
  }

  void _changeFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      // Reset ke halaman pertama saat filter berubah
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _filteredMedia;

    return Scaffold(
      body: Stack(
        children: [
          // Layer 1: Content Scrolling (PageView)
          displayList.isEmpty
              ? const Center(child: Text("Tidak ada konten"))
              : PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    return ContentPage(item: displayList[index]);
                  },
                ),

          // Layer 2: Top Navigation / Filter Bar
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterButton('Semua', 'all'),
                const SizedBox(width: 15),
                Container(width: 1, height: 15, color: Colors.white54),
                const SizedBox(width: 15),
                _buildFilterButton('Gambar', 'image'),
                const SizedBox(width: 15),
                Container(width: 1, height: 15, color: Colors.white54),
                const SizedBox(width: 15),
                _buildFilterButton('Video', 'video'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String title, String filterKey) {
    final bool isSelected = _currentFilter == filterKey;
    return GestureDetector(
      onTap: () => _changeFilter(filterKey),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
              shadows: const [
                Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black54),
              ],
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 20,
              color: Colors.white,
            )
        ],
      ),
    );
  }
}

class ContentPage extends StatelessWidget {
  final MediaItem item;

  const ContentPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Background Image / Video Placeholder
        Image.network(
          item.url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: Colors.grey,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[900],
            child: const Center(child: Icon(Icons.broken_image, color: Colors.white)),
          ),
        ),

        // 2. Video Overlay (If it's a video)
        if (item.type == 'video')
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.all(20),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),

        // 3. Bottom Info (Username & Description)
        Positioned(
          left: 15,
          right: 15, 
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [
                    Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black54),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  shadows: [
                    Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black54),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (item.type == 'video')
                Row(
                  children: const [
                    Icon(Icons.music_note, size: 15, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      'Original Sound - Music Artist', 
                      style: TextStyle(
                        fontSize: 12, 
                        color: Colors.white,
                        shadows: [
                          Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black54),
                        ],
                      )
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
