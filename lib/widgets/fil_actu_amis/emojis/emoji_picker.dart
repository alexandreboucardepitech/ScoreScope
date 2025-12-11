import 'package:flutter/material.dart';
import 'package:scorescope/models/util/emoji.dart';
import 'package:scorescope/utils/emoji/emojis_loader.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class EmojiPickerSheet extends StatefulWidget {
  final List<String> recent;
  final void Function(String emoji) onPick;

  const EmojiPickerSheet(
      {super.key, required this.recent, required this.onPick});

  @override
  State<EmojiPickerSheet> createState() => _EmojiPickerSheetState();
}

class _EmojiPickerSheetState extends State<EmojiPickerSheet> {
  final int pageSize = 120;
  final List<Emoji> items = [];
  final ScrollController scrollController = ScrollController();

  String query = '';
  bool loaded = false;
  bool isLoadingMore = false;
  int totalMatching = 0;
  int offset = 0;

  OverlayEntry? _variantsOverlay;

  @override
  void initState() {
    super.initState();
    initLoad();
    scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    _removeVariantsOverlay();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> initLoad() async {
    setState(() {
      items.clear();
      offset = 0;
      loaded = false;
      isLoadingMore = false;
    });

    totalMatching = await EmojiLoader.countMatching(query);
    final chunk = await EmojiLoader.fetchChunk(
        offset: offset, limit: pageSize, query: query);
    items.addAll(chunk);
    offset += chunk.length;

    setState(() {
      loaded = true;
    });
  }

  void onScroll() {
    if (!isLoadingMore &&
        scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore) return;
    if (offset >= totalMatching) return;

    setState(() => isLoadingMore = true);
    final chunk = await EmojiLoader.fetchChunk(
        offset: offset, limit: pageSize, query: query);
    items.addAll(chunk);
    offset += chunk.length;
    setState(() => isLoadingMore = false);
  }

  Future<void> onSearchChanged(String q) async {
    query = q;
    await initLoad();
  }

  void onEmojiTap(Emoji e) {
    widget.onPick(e.emoji);
  }


  void _removeVariantsOverlay() {
    if (_variantsOverlay != null) {
      _variantsOverlay!.remove();
      _variantsOverlay = null;
    }
  }

  void _showVariantsOverlay(BuildContext tileContext, Emoji e) {
    _removeVariantsOverlay();

    if (e.variantEmojis.isEmpty) {
      widget.onPick(e.emoji);
      return;
    }

    final overlay = Overlay.of(context);

    final RenderBox rb = tileContext.findRenderObject() as RenderBox;
    final tileSize = rb.size;
    final tilePos = rb.localToGlobal(Offset.zero);

    const double variantTileSize = 44.0;
    final int count = e.variantEmojis.length;
    final double totalWidth = count * variantTileSize + (count - 1) * 8.0;
    final double screenWidth = MediaQuery.of(context).size.width;

    double overlayLeft = tilePos.dx + tileSize.width / 2 - totalWidth / 2;
    overlayLeft = overlayLeft.clamp(8.0, screenWidth - totalWidth - 8.0);
    final double overlayTop = tilePos.dy - variantTileSize - 12.0;

    _variantsOverlay = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeVariantsOverlay,
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: overlayLeft,
              top: overlayTop,
              child: Material(
                color: ColorPalette.tileSelected(context).withOpacity(1.0),
                borderRadius: BorderRadius.circular(12),
                elevation: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 8)
                    ],
                    border: Border.all(color: ColorPalette.border(context)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final v in e.variantEmojis) ...[
                        GestureDetector(
                          onTap: () {
                            _removeVariantsOverlay();
                            widget.onPick(v);
                          },
                          child: Container(
                            width: variantTileSize,
                            height: variantTileSize,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: ColorPalette.tileBackground(context),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: ColorPalette.border(context)),
                            ),
                            child:
                                Text(v, style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_variantsOverlay!);
  }

  Map<String, List<Emoji>> _groupByCategory(List<Emoji> list) {
    final Map<String, List<Emoji>> map = {};
    for (final e in list) {
      final cat = e.category.isNotEmpty ? e.category : 'Autres';
      final group = map.putIfAbsent(cat, () => []);
      group.add(e);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final halfHeight = MediaQuery.of(context).size.height * 0.5;
    final viewInsets = MediaQuery.of(context).viewInsets;

    final grouped = _groupByCategory(items);
    final categoryKeys = grouped.keys.toList();

    final List<Widget> sections = [];

    if (widget.recent.isNotEmpty) {
      sections.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  'Récents',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: ColorPalette.textPrimary(context),
                  ),
                ),
              ),
              SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.recent.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final e = widget.recent[i];
                    return GestureDetector(
                      onTap: () => widget.onPick(e),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: ColorPalette.border(context)),
                          color: ColorPalette.tileBackground(context),
                        ),
                        child: Text(
                          e,
                          style: TextStyle(
                              fontSize: 20,
                              color: ColorPalette.textPrimary(context)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    for (final cat in categoryKeys) {
      final listForCat = grouped[cat]!;
      sections.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: ColorPalette.textPrimary(context),
                  ),
                ),
              ),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listForCat.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (ctx, i) {
                  final e = listForCat[i];
                  return Builder(builder: (tileContext) {
                    return GestureDetector(
                      onTap: () => onEmojiTap(e),
                      onLongPress: () => _showVariantsOverlay(tileContext, e),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorPalette.tileBackground(context),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: ColorPalette.border(context)),
                        ),
                        child: Text(
                          e.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        ),
      );
    }

    final Widget bodyContent = !loaded
        ? Center(
            child: CircularProgressIndicator(
              color: ColorPalette.textAccent(context),
            ),
          )
        : NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollEndNotification) {
                if (!isLoadingMore &&
                    scrollController.position.pixels >=
                        scrollController.position.maxScrollExtent - 200) {
                  loadMore();
                }
              }
              return false;
            },
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                ...sections,
                if (isLoadingMore)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ColorPalette.textAccent(context)),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          );

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: halfHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),

                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un emoji par nom ou catégorie…',
                    hintStyle:
                        TextStyle(color: ColorPalette.textPrimary(context)),
                    prefixIcon: Icon(Icons.search,
                        color: ColorPalette.textSecondary(context)),
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  style: TextStyle(color: ColorPalette.textPrimary(context)),
                  onChanged: (v) {
                    onSearchChanged(v);
                  },
                ),
                const SizedBox(height: 8),

                Expanded(child: bodyContent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
