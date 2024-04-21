import "dart:typed_data";

import "package:camera_awesome/src/photofilters/filters/filters.dart";

///The [ImageSubFilter] class is the abstract class to define any ImageSubFilter.
mixin ImageSubFilter on SubFilter {
  ///Apply the [SubFilter] to an Image.
  void apply(Uint8List pixels, int width, int height);
}

class ImageFilter extends Filter {

  ImageFilter({required super.name})
      : subFilters = <ImageSubFilter>[];
  final List<ImageSubFilter> subFilters;

  ///Apply the [SubFilter] to an Image.
  @override
  void apply(Uint8List pixels, int width, int height) {
    for (final ImageSubFilter subFilter in subFilters) {
      subFilter.apply(pixels, width, height);
    }
  }

  void addSubFilter(ImageSubFilter subFilter) {
    subFilters.add(subFilter);
  }

  void addSubFilters(List<ImageSubFilter> subFilters) {
    this.subFilters.addAll(subFilters);
  }
}
