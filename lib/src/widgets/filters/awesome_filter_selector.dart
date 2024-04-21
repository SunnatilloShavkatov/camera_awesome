import "package:camera_awesome/camerawesome_plugin.dart";
import "package:carousel_slider/carousel_slider.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

class AwesomeFilterSelector extends StatefulWidget {
  const AwesomeFilterSelector({
    super.key,
    required this.state,
    required this.filterListPosition,
    required this.filterListPadding,
    required this.filterListBackgroundColor,
    required this.indicator,
  });

  final PhotoCameraState state;
  final FilterListPosition filterListPosition;
  final Widget indicator;
  final EdgeInsets? filterListPadding;
  final Color? filterListBackgroundColor;

  @override
  State<AwesomeFilterSelector> createState() => _AwesomeFilterSelectorState();
}

class _AwesomeFilterSelectorState extends State<AwesomeFilterSelector> {
  final CarouselController _controller = CarouselController();
  int? _textureId;
  int _selected = 0;

  List<String> get presetsIds =>
      widget.state.availableFilters!.map((AwesomeFilter e) => e.id).toList();

  @override
  void initState() {
    super.initState();

    _selected = presetsIds.indexOf(widget.state.filter.id);

    widget.state.previewTextureId(0).then((int? textureId) {
      setState(() {
        _textureId = textureId;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      widget.indicator,
      Container(
        padding: widget.filterListPadding,
        color: widget.filterListBackgroundColor,
        child: Stack(
          children: <Widget>[
            CarouselSlider(
              options: CarouselOptions(
                height: 60,
                initialPage: _selected,
                onPageChanged: (int index, CarouselPageChangedReason reason) {
                  final AwesomeFilter filter = awesomePresetFiltersList[index];

                  setState(() {
                    _selected = index;
                  });

                  HapticFeedback.selectionClick();
                  widget.state.setFilter(filter);
                },
                enableInfiniteScroll: false,
                viewportFraction: 0.165,
              ),
              carouselController: _controller,
              items: awesomePresetFiltersList
                  .map(
                    (AwesomeFilter filter) => Builder(
                      builder: (BuildContext context) => AwesomeBouncingWidget(
                        onTap: () {
                          _controller.animateToPage(
                            presetsIds.indexOf(filter.id),
                            curve: Curves.fastLinearToSlowEaseIn,
                            duration: const Duration(milliseconds: 700),
                          );
                        },
                        child: _FilterPreview(
                          filter: filter.preview,
                          textureId: _textureId,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            IgnorePointer(
              child: Center(
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(9)),
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
    return Column(
      children: widget.filterListPosition == FilterListPosition.belowButton
          ? children
          : children.reversed.toList(),
    );
  }
}

class _FilterPreview extends StatelessWidget {
  const _FilterPreview({
    required this.filter,
    required this.textureId,
  });

  final ColorFilter filter;
  final int? textureId;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(9)),
        child: SizedBox(
          width: 60,
          height: 60,
          child: textureId != null
              ? ColorFiltered(
                  colorFilter: filter,
                  child: OverflowBox(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: 60,
                        height: 60 / (9 / 16),
                        child: Texture(textureId: textureId!),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      );
}
