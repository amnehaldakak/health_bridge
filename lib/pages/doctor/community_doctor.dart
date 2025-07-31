import 'package:flutter/material.dart';

/// Community page for doctors with a professional header design
/// featuring banner image, community information, and action buttons.
class CommunityDoctor extends StatefulWidget {
  const CommunityDoctor({super.key});

  @override
  State<CommunityDoctor> createState() => _CommunityDoctorState();
}

class _CommunityDoctorState extends State<CommunityDoctor> {
  bool _isMember = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildCommunityHeader(),
          _buildCommunityContent(),
        ],
      ),
    );
  }

  /// Builds the community header with banner, profile info, and action buttons
  Widget _buildCommunityHeader() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Banner Image
            _buildBannerImage(),
            // Gradient overlay for better text readability
            _buildGradientOverlay(),
            // Community information
            _buildCommunityInfo(),
            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// Builds the banner image with gradient background
  Widget _buildBannerImage() {
    return Container(
      width: double.infinity,
      height: 200.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade300,
            Colors.purple.shade400,
            Colors.orange.shade500,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: BannerPainter(),
      ),
    );
  }

  /// Builds gradient overlay for better text contrast
  Widget _buildGradientOverlay() {
    return Container(
      width: double.infinity,
      height: 200.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.6),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
    );
  }

  /// Builds community information section
  Widget _buildCommunityInfo() {
    return Positioned(
      left: 16.0,
      bottom: 16.0,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile Picture
            Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/50x50'),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.white, width: 2.0),
              ),
            ),
            const SizedBox(width: 12.0),
            // Community Text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'HealthBridge',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Text(
                  'Community',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds action buttons section
  Widget _buildActionButtons() {
    return Positioned(
      right: 16.0,
      bottom: 16.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subscribe Button
          ElevatedButton(
            onPressed: _isMember ? null : _handleSubscribe,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              'Subscribe',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8.0),
          // Member Status Button
          Container(
            decoration: BoxDecoration(
              color: _isMember ? Colors.green : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: PopupMenuButton<String>(
              onSelected: _handleMemberAction,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isMember ? 'You are a member' : 'Not a member',
                      style: TextStyle(
                        color: _isMember ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: _isMember ? Colors.white : Colors.grey.shade700,
                      size: 20.0,
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'leave',
                  child: Row(
                    children: [
                      const Icon(Icons.exit_to_app, color: Colors.red),
                      const SizedBox(width: 8.0),
                      const Text('Leave Community'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      const Icon(Icons.settings, color: Colors.grey),
                      const SizedBox(width: 8.0),
                      const Text('Community Settings'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main community content
  Widget _buildCommunityContent() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return _buildWelcomeSection();
          } else if (index == 1) {
            return _buildStatsSection();
          } else if (index == 2) {
            return _buildCommunityPostsSection();
          }
          return null;
        },
        childCount: 3,
      ),
    );
  }

  /// Builds welcome section
  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to HealthBridge Community',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Connect with fellow healthcare professionals, share knowledge, and stay updated with the latest medical practices.',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds community statistics section
  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Members', '1,234'),
          _buildStatItem('Posts', '567'),
          _buildStatItem('Topics', '89'),
        ],
      ),
    );
  }

  /// Builds individual stat item
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Builds community posts section
  Widget _buildCommunityPostsSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Community Posts',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildSocialMediaPost(
            profileImage:
                'https://via.placeholder.com/40x40/4A90E2/FFFFFF?text=Dr',
            authorName: 'Dr. Sarah Johnson',
            timestamp: '2 hours ago',
            title: 'Latest advances in cardiology treatments',
            content:
                'Just attended an amazing conference on new cardiology treatments. The new minimally invasive procedures are showing promising results. Here are some key takeaways from the session.',
            imageUrl:
                'https://via.placeholder.com/400x300/FF6B6B/FFFFFF?text=Cardiology+Conference',
            likes: 45,
            comments: 12,
            shares: 8,
            views: 234,
            source: 'Dr. Sarah Johnson',
            postId: 'cardiology_post',
          ),
          const SizedBox(height: 16.0),
          _buildSocialMediaPost(
            profileImage:
                'https://via.placeholder.com/40x40/50C878/FFFFFF?text=Dr',
            authorName: 'Dr. Michael Chen',
            timestamp: '5 hours ago',
            title: 'Best practices for patient communication',
            content:
                'Effective communication is crucial in healthcare. Here are some proven techniques I\'ve found helpful in my practice. The key is to listen actively and explain complex medical terms in simple language.',
            imageUrl:
                'https://via.placeholder.com/400x300/4ECDC4/FFFFFF?text=Patient+Communication',
            likes: 32,
            comments: 7,
            shares: 15,
            views: 189,
            source: 'Dr. Michael Chen',
            postId: 'communication_post',
          ),
          const SizedBox(height: 16.0),
          _buildSocialMediaPost(
            profileImage:
                'https://via.placeholder.com/40x40/9B59B6/FFFFFF?text=Dr',
            authorName: 'Dr. Emily Rodriguez',
            timestamp: '1 day ago',
            title: 'New medical device recommendations',
            content:
                'Recently tested some new medical devices that could revolutionize our practice. The accuracy and efficiency improvements are remarkable. Sharing my experience with the community.',
            imageUrl:
                'https://via.placeholder.com/400x300/FFA726/FFFFFF?text=Medical+Devices',
            likes: 67,
            comments: 23,
            shares: 31,
            views: 456,
            source: 'Dr. Emily Rodriguez',
            postId: 'devices_post',
          ),
          const SizedBox(height: 16.0),
          _buildSocialMediaPost(
            profileImage:
                'https://via.placeholder.com/40x40/E74C3C/FFFFFF?text=Dr',
            authorName: 'Dr. James Wilson',
            timestamp: '2 days ago',
            title: 'Mental health awareness in medical practice',
            content:
                'Mental health is as important as physical health. As healthcare providers, we need to be more aware of our patients\' mental well-being. Here are some resources and tips.',
            imageUrl:
                'https://via.placeholder.com/400x300/8E44AD/FFFFFF?text=Mental+Health',
            likes: 89,
            comments: 34,
            shares: 42,
            views: 678,
            source: 'Dr. James Wilson',
            postId: 'mental_health_post',
          ),
        ],
      ),
    );
  }

  /// Builds a social media-style post
  Widget _buildSocialMediaPost({
    required String profileImage,
    required String authorName,
    required String timestamp,
    required String title,
    required String content,
    required String imageUrl,
    required int likes,
    required int comments,
    required int shares,
    required int views,
    required String source,
    required String postId,
  }) {
    return GestureDetector(
      onTap: () => _navigateToDetailedPost(postId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Profile picture
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(profileImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  // Author info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          timestamp,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Dropdown menu
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with icon
                  Row(
                    children: [
                      Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          color: Colors.white,
                          size: 14.0,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  // Main content
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  // Hashtag
                  Text(
                    '#Healthcare #MedicalCommunity #HealthBridge',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Image section
            if (imageUrl.isNotEmpty)
              Container(
                width: double.infinity,
                height: 200.0,
                margin: const EdgeInsets.only(top: 12.0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            // Source section
            if (imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Source: $source',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            // Engagement metrics
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Likes
                  GestureDetector(
                    onTap: () => _navigateToDetailedPost(postId),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite,
                            color: Colors.red, size: 20.0),
                        const SizedBox(width: 4.0),
                        Text(
                          likes.toString(),
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  // Comments
                  GestureDetector(
                    onTap: () => _navigateToDetailedPost(postId),
                    child: Row(
                      children: [
                        const Icon(Icons.comment,
                            color: Colors.grey, size: 20.0),
                        const SizedBox(width: 4.0),
                        Text(
                          comments.toString(),
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  // Shares
                  Row(
                    children: [
                      const Icon(Icons.share, color: Colors.grey, size: 20.0),
                      const SizedBox(width: 4.0),
                      Text(
                        shares.toString(),
                        style: const TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Views
                  Row(
                    children: [
                      const Icon(Icons.visibility,
                          color: Colors.grey, size: 20.0),
                      const SizedBox(width: 4.0),
                      Text(
                        views.toString(),
                        style: const TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigates to detailed post page
  void _navigateToDetailedPost(String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailedPostPage(postId: postId),
      ),
    );
  }

  /// Handles subscribe action
  void _handleSubscribe() {
    setState(() {
      _isMember = true;
    });
    _showSnackBar('Successfully subscribed to HealthBridge Community!');
  }

  /// Handles member action from popup menu
  void _handleMemberAction(String action) {
    switch (action) {
      case 'leave':
        setState(() {
          _isMember = false;
        });
        _showSnackBar('You have left the community');
        break;
      case 'settings':
        _showSnackBar('Community settings coming soon');
        break;
    }
  }

  /// Shows snack bar with message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }
}

/// Detailed post page with comments section
class DetailedPostPage extends StatefulWidget {
  final String postId;

  const DetailedPostPage({super.key, required this.postId});

  @override
  State<DetailedPostPage> createState() => _DetailedPostPageState();
}

class _DetailedPostPageState extends State<DetailedPostPage> {
  final TextEditingController _commentController = TextEditingController();
  bool _showFullText = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPostContent(),
            _buildCommentsSection(),
          ],
        ),
      ),
    );
  }

  /// Builds the main post content
  Widget _buildPostContent() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://via.placeholder.com/40x40/4A90E2/FFFFFF?text=Dr'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HealthBridge Community',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        '10 Aug at 14:00',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon:
                      const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: const Icon(
                        Icons.public,
                        color: Colors.white,
                        size: 14.0,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'HealthBridge Community is now available to all healthcare professionals',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Text(
                  _showFullText
                      ? 'Search and browse thousands of medical resources, treatment protocols, case studies, medical illustrations, and even educational games. Connect with fellow healthcare professionals, share knowledge, and stay updated with the latest medical practices and research findings. Our community provides a platform for continuous learning and professional development in the healthcare field.'
                      : 'Search and browse thousands of medical resources, treatment protocols, case studies, medical illustrations, and even educational games...',
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                if (!_showFullText)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showFullText = true;
                      });
                    },
                    child: Text(
                      'Show full...',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ),
                const SizedBox(height: 8.0),
                const Text('💡', style: TextStyle(fontSize: 16.0)),
              ],
            ),
          ),
          // Image
          Container(
            width: double.infinity,
            height: 300.0,
            margin: const EdgeInsets.only(top: 12.0),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://via.placeholder.com/400x300/FF6B6B/FFFFFF?text=Healthcare+Community'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Engagement metrics
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 20.0),
                const SizedBox(width: 4.0),
                const Text('21', style: TextStyle(fontSize: 14.0)),
                const SizedBox(width: 16.0),
                const Icon(Icons.comment, color: Colors.grey, size: 20.0),
                const SizedBox(width: 4.0),
                const Text('1', style: TextStyle(fontSize: 14.0)),
                const SizedBox(width: 16.0),
                const Icon(Icons.share, color: Colors.grey, size: 20.0),
                const SizedBox(width: 4.0),
                const Text('2', style: TextStyle(fontSize: 14.0)),
                const Spacer(),
                const Icon(Icons.visibility, color: Colors.grey, size: 20.0),
                const SizedBox(width: 4.0),
                const Text('985', style: TextStyle(fontSize: 14.0)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the comments section
  Widget _buildCommentsSection() {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comments header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'First interesting',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(width: 4.0),
                const Icon(Icons.keyboard_arrow_down, size: 16.0),
              ],
            ),
          ),
          // Individual comments
          _buildComment(
            profileImage:
                'https://via.placeholder.com/32x32/FF6B6B/FFFFFF?text=J',
            authorName: 'Jackson Allen',
            comment:
                'This is exactly what the medical community needed! Great initiative.',
            timestamp: '5 Sep at 10:49',
            likes: 3,
          ),
          _buildComment(
            profileImage:
                'https://via.placeholder.com/32x32/4ECDC4/FFFFFF?text=E',
            authorName: 'Evan Phillips',
            comment:
                'Looking forward to connecting with other healthcare professionals here.',
            timestamp: '5 Sep at 11:23',
            likes: 1,
          ),
          _buildComment(
            profileImage:
                'https://via.placeholder.com/32x32/45B7D1/FFFFFF?text=C',
            authorName: 'Camila Reed',
            comment:
                'The resources section looks promising. Can\'t wait to explore!',
            timestamp: '5 Sep at 12:15',
            likes: 2,
          ),
          // Show next comments
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Show next comments',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.blue.shade600,
              ),
            ),
          ),
          // Comment input
          _buildCommentInput(),
        ],
      ),
    );
  }

  /// Builds individual comment
  Widget _buildComment({
    required String profileImage,
    required String authorName,
    required String comment,
    required String timestamp,
    required int likes,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(profileImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      timestamp,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  comment,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Text(
                      'Reply',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Row(
                      children: [
                        const Icon(Icons.favorite_border,
                            size: 16.0, color: Colors.grey),
                        if (likes > 0) ...[
                          const SizedBox(width: 4.0),
                          Text(
                            likes.toString(),
                            style: const TextStyle(
                                fontSize: 12.0, color: Colors.grey),
                          ),
                        ],
                      ],
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

  /// Builds comment input section
  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.pink.shade300,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.attach_file, color: Colors.grey),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.camera_alt, color: Colors.grey),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.emoji_emotions, color: Colors.grey),
          ),
          IconButton(
            onPressed: () {
              if (_commentController.text.isNotEmpty) {
                // Handle comment submission
                _commentController.clear();
              }
            },
            icon: const Icon(Icons.send, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for banner background design
class BannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        center: Alignment.topRight,
        radius: 0.8,
        colors: [
          Colors.orange.shade200,
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw sun-like circle
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      30.0,
      paint,
    );

    // Draw wave-like shapes
    final wavePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.orange.shade100.withOpacity(0.3);

    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.7,
      size.width,
      size.height * 0.6,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
