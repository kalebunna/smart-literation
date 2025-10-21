import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:education_game_app/models/summary_model.dart';
import 'package:education_game_app/services/api_service.dart';
import 'package:education_game_app/providers/material_provider.dart';
import 'package:education_game_app/screens/final_test_screen.dart';

class MaterialSummaryScreen extends StatefulWidget {
  final int materialId;
  final int? quizScore;
  final int? totalQuizQuestions;

  const MaterialSummaryScreen({
    Key? key,
    required this.materialId,
    this.quizScore,
    this.totalQuizQuestions,
  }) : super(key: key);

  @override
  _MaterialSummaryScreenState createState() => _MaterialSummaryScreenState();
}

class _MaterialSummaryScreenState extends State<MaterialSummaryScreen>
    with TickerProviderStateMixin {
  List<SummaryParagraph> _paragraphs = [];
  bool _isLoading = true;
  int _currentPageIndex = 0;
  PageController _pageController = PageController();

  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSummary();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _bounceAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _slideController.forward();
    _bounceController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSummary() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final paragraphs =
          await apiService.getSummaryByMaterialId(widget.materialId);

      setState(() {
        _paragraphs = paragraphs;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _nextPage() {
    if (_currentPageIndex < _paragraphs.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToFinalTest() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FinalTestScreen(
          materialId: widget.materialId,
          midtestScore: widget.quizScore ?? 0,
          totalMidtestQuestions: widget.totalQuizQuestions ?? 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6B73FF),
              Color(0xFF9B59B6),
              Color(0xFFE74C3C),
              Color(0xFFF39C12),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : _paragraphs.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        _buildHeader(),
                        _buildProgressIndicator(),
                        Expanded(child: _buildContent()),
                        _buildNavigationButtons(),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final material = Provider.of<MaterialProvider>(context)
        .getMaterialById(widget.materialId);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Color(0xFF6B73FF)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text(
                    '📚',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rangkuman: ${material?.title ?? 'Materi'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B73FF),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: List.generate(_paragraphs.length, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: index <= _currentPageIndex
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentPageIndex + 1}/${_paragraphs.length}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B73FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: const EdgeInsets.all(16),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              itemCount: _paragraphs.length,
              itemBuilder: (context, index) {
                return _buildPageContent(_paragraphs[index]);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageContent(SummaryParagraph paragraph) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 8),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page header with emoji
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '📄',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Halaman ${paragraph.paragraphNumber}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Html(
                      data: paragraph.paragraph,
                      style: {
                        "body": Style(
                          fontSize: FontSize(16),
                          color: const Color(0xFF2C3E50),
                          lineHeight: const LineHeight(1.6),
                          fontFamily: 'Poppins',
                        ),
                        "h1": Style(
                          fontSize: FontSize(24),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6B73FF),
                          margin: Margins.only(bottom: 12),
                        ),
                        "h2": Style(
                          fontSize: FontSize(20),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF9B59B6),
                          margin: Margins.only(bottom: 10),
                        ),
                        "h3": Style(
                          fontSize: FontSize(18),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE74C3C),
                          margin: Margins.only(bottom: 8),
                        ),
                        "p": Style(
                          fontSize: FontSize(16),
                          margin: Margins.only(bottom: 12),
                        ),
                        "blockquote": Style(
                          backgroundColor: const Color(0xFFF8F9FA),
                          border: const Border(
                            left: BorderSide(
                              color: Color(0xFF4CAF50),
                              width: 4,
                            ),
                          ),
                          padding: HtmlPaddings.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          margin: Margins.only(bottom: 12),
                          fontStyle: FontStyle.italic,
                        ),
                        "ul": Style(
                          margin: Margins.only(bottom: 12),
                        ),
                        "ol": Style(
                          margin: Margins.only(bottom: 12),
                        ),
                        "li": Style(
                          margin: Margins.only(bottom: 4),
                        ),
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationButtons() {
    bool isLastPage = _currentPageIndex == _paragraphs.length - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Previous Button
          if (_currentPageIndex > 0)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _previousPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6B73FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_ios, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Sebelumnya',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Next Button or Final Test Button
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: _currentPageIndex > 0 ? 8 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLastPage ? _goToFinalTest : _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLastPage
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF6B73FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLastPage) ...[
                      const Icon(Icons.quiz, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Tes Akhir',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Selanjutnya',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 8),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '📚',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Rangkuman',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Rangkuman untuk materi ini belum tersedia.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B73FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Kembali',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
