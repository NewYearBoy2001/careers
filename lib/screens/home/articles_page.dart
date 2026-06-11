import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:careers/bloc/article/article_bloc.dart';
import 'package:careers/bloc/article/article_event.dart';
import 'package:careers/bloc/article/article_state.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/constants/app_text_styles.dart';
import 'package:careers/data/models/article_model.dart';
import 'package:careers/utils/responsive/responsive.dart';


class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _showSearch = false;
  late AnimationController _headerAnim;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _headerAnim.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ArticleBloc>().add(FetchMoreArticles());
    }
  }

  Future<void> _onRefresh() async {
    context.read<ArticleBloc>().add(RefreshArticles());
    await Future.any([
      Future.delayed(const Duration(seconds: 5)),
      Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        final s = context.read<ArticleBloc>().state;
        return s is! ArticleLoaded && s is! ArticleError;
      }),
    ]);
  }

  void _onSearchSubmit(String value) {
    if (value.trim().isEmpty) {
      context.read<ArticleBloc>().add(ClearArticleSearch());
    } else {
      context.read<ArticleBloc>().add(SearchArticles(value.trim()));
    }
  }

  void _toggleSearch() {
    setState(() => _showSearch = !_showSearch);
    if (!_showSearch) {
      _searchController.clear();
      context.read<ArticleBloc>().add(ClearArticleSearch());
      _searchFocus.unfocus();
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        _searchFocus.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      body: BlocBuilder<ArticleBloc, ArticleState>(
        builder: (context, state) {
          return NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildSliverAppBar(innerBoxIsScrolled),
            ],
            body: _buildBody(state),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(bool collapsed) {
    return SliverAppBar(
      expandedHeight: _showSearch ? 60 : Responsive.h(22),
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          if (_showSearch) {
            _toggleSearch();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      actions: [
        if (_showSearch && _searchController.text.isNotEmpty)
          TextButton(
            onPressed: () {
              _searchController.clear();
              context.read<ArticleBloc>().add(ClearArticleSearch());
              setState(() {});
            },
            child: Text(
              'Clear',
              style: TextStyle(
                fontSize: Responsive.sp(13),
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close : Icons.search,
              color: Colors.white,
              size: Responsive.w(5.5),
            ),
            onPressed: _toggleSearch,
          ),
      ],
      title: _showSearch
          ? TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        onSubmitted: _onSearchSubmit,
        onChanged: (v) {
          setState(() {});
          if (v.isEmpty) {
            context.read<ArticleBloc>().add(ClearArticleSearch());
          }
        },
        style: TextStyle(
          fontSize: Responsive.sp(14),
          color: Colors.white,
        ),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: 'Search articles...',
          hintStyle: TextStyle(
            fontSize: Responsive.sp(14),
            color: Colors.white54,
          ),
          border: InputBorder.none,
        ),
      )
          : null,
      flexibleSpace: _showSearch
          ? null
          : FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _buildHeader(),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerFade,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1F4040),
              Color(0xFF306060),
              Color(0xFF3D7A72),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -Responsive.h(4),
              right: -Responsive.w(8),
              child: Container(
                width: Responsive.w(50),
                height: Responsive.w(50),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              bottom: Responsive.h(2),
              left: -Responsive.w(10),
              child: Container(
                width: Responsive.w(40),
                height: Responsive.w(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),
            // Content
            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.w(5),
                    Responsive.h(5),
                    Responsive.w(5),
                    Responsive.h(2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Eyebrow label
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(2.5),
                          vertical: Responsive.h(0.4),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.teal.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'CAREER INSIGHTS',
                          style: TextStyle(
                            fontSize: Responsive.sp(9),
                            fontWeight: FontWeight.w700,
                            color: AppColors.teal3,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.h(1.2)),
                      // Main headline
                      Text(
                        'Knowledge\nto grow.',
                        style: AppTextStyles.pageTitle(fontSize: Responsive.sp(28)).copyWith(
                          height: 1.15,
                          letterSpacing: -0.8,
                        ),
                      ),
                      SizedBox(height: Responsive.h(0.8)),
                      Text(
                        'In-depth guides and industry insights',
                        style: TextStyle(
                          fontSize: Responsive.sp(12),
                          color: Colors.white60,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ArticleState state) {
    if (state is ArticleSearchLoading ||
        state is ArticleInitial ||
        state is ArticleLoading) {
      return _buildSkeletonLoader();
    }

    if (state is ArticleError) {
      return _buildError(state.message);
    }

    if (state is ArticleLoaded && state.articles.isEmpty) {
      return _buildEmpty(state);
    }

    if (state is ArticleLoaded) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            // Header strip
            SliverToBoxAdapter(child: _buildListHeader(state)),
            // Article list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return _ArticleListTile(
                    article: state.articles[index],
                    index: index,
                  );
                },
                childCount: state.articles.length,
              ),
            ),
            // Bottom loader
            SliverToBoxAdapter(
              child: state is ArticleLoadingMore
                  ? Padding(
                padding: EdgeInsets.symmetric(vertical: Responsive.h(2)),
                child: const Center(
                  child:
                  CircularProgressIndicator(color: AppColors.primary),
                ),
              )
                  : SizedBox(height: Responsive.h(4)),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildListHeader(ArticleLoaded state) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(5),
        Responsive.h(2),
        Responsive.w(5),
        Responsive.h(0.5),
      ),
      child: Row(
        children: [
          Text(
            state.isSearching
                ? 'Results for "${state.searchQuery}"'
                : 'All Posts',
            style: TextStyle(
              fontSize: Responsive.sp(13),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(2.5),
              vertical: Responsive.h(0.3),
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${state.total}',
              style: TextStyle(
                fontSize: Responsive.sp(11),
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: EdgeInsets.only(top: Responsive.h(1)),
      itemCount: 5,
      itemBuilder: (context, index) => _SkeletonTile(index: index),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.w(5)),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.wifi_off_rounded,
                color: AppColors.primary, size: Responsive.w(10)),
          ),
          SizedBox(height: Responsive.h(2)),
          Text(message,
              style: TextStyle(
                  fontSize: Responsive.sp(13),
                  color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildEmpty(ArticleLoaded state) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              color: AppColors.textSecondary, size: Responsive.w(12)),
          SizedBox(height: Responsive.h(1.5)),
          Text(
            state.isSearching
                ? 'No results for\n"${state.searchQuery}"'
                : 'No articles available.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: Responsive.sp(14),
                color: AppColors.textSecondary,
                height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ─── Regular article list tile ────────────────────────────────────────────────

class _ArticleListTile extends StatelessWidget {
  final ArticleModel article;
  final int index;
  const _ArticleListTile({required this.article, required this.index});

  // Cycle through a few accent tones for the left border
  Color get _accentColor {
    const colors = [
      AppColors.primary,
      AppColors.teal1,
      AppColors.tealnetwork,
      AppColors.primaryLight,
      AppColors.teal2,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(article.fileUrl);
        if (await canLaunchUrl(uri)) {
          launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(
          Responsive.w(4),
          0,
          Responsive.w(4),
          Responsive.h(1.2),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar
              Container(
                width: 3.5,
                decoration: BoxDecoration(
                  color: _accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.w(3.5),
                    Responsive.h(1.4),
                    Responsive.w(3),
                    Responsive.h(1.4),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.title,
                              style: AppTextStyles.cardTitle(fontSize: Responsive.sp(13)).copyWith(
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: Responsive.h(0.8)),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: Responsive.w(2.8),
                                  color: AppColors.textHint,
                                ),
                                SizedBox(width: Responsive.w(1)),
                                Text(
                                  article.createdAt.substring(0, 10),
                                  style: TextStyle(
                                    fontSize: Responsive.sp(10),
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: Responsive.w(2)),
                      // Icon box
                      Container(
                        width: Responsive.w(10),
                        height: Responsive.w(10),
                        decoration: BoxDecoration(
                          color: _accentColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.description_outlined,
                          color: _accentColor,
                          size: Responsive.w(5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Skeleton loader tile ─────────────────────────────────────────────────────

class _SkeletonTile extends StatefulWidget {
  final int index;
  const _SkeletonTile({required this.index});

  @override
  State<_SkeletonTile> createState() => _SkeletonTileState();
}

class _SkeletonTileState extends State<_SkeletonTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _shimmer = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) {
        final base = Color.lerp(
            const Color(0xFFE8ECEC), const Color(0xFFF4F6F6), _shimmer.value)!;
        return Container(
          margin: EdgeInsets.fromLTRB(
            Responsive.w(4),
            0,
            Responsive.w(4),
            Responsive.h(1.2),
          ),
          height: Responsive.h(8),
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(14),
          ),
        );
      },
    );
  }
}

// ─── Dot grid painter for featured card decoration ────────────────────────────

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    const spacing = 14.0;
    const dotRadius = 1.5;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}