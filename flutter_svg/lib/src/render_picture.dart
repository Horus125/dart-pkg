import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'picture_stream.dart';

@immutable
class RawPicture extends LeafRenderObjectWidget {
  const RawPicture(
    this.picture, {
    Key key,
    this.matchTextDirection = false,
    this.allowDrawingOutsideViewBox = false,
  }) : super(key: key);

  final PictureInfo picture;
  final bool matchTextDirection;

  final bool allowDrawingOutsideViewBox;

  @override
  RenderPicture createRenderObject(BuildContext context) {
    return new RenderPicture(
        picture: picture,
        matchTextDirection: matchTextDirection,
        textDirection: matchTextDirection ? Directionality.of(context) : null,
        allowDrawingOutsideViewBox: allowDrawingOutsideViewBox);
  }

  @override
  void updateRenderObject(BuildContext context, RenderPicture renderObject) {
    renderObject
      ..picture = picture
      ..matchTextDirection = matchTextDirection
      ..allowDrawingOutsideViewBox = allowDrawingOutsideViewBox
      ..textDirection = matchTextDirection ? Directionality.of(context) : null;
  }
}

/// A picture in the render tree.
///
/// The render picture will draw based on its parents dimensions maintaining
/// its aspect ratio.
///
/// If `matchTextDirection` is true, the picture will be flipped horizontally in
/// [TextDirection.rtl] contexts.  If `allowDrawingOutsideViewBox` is true, the
/// picture will be allowed to draw beyond the constraints of its viewbox; this
/// flag should be used with care, as it may result in unexpected effects or
/// additional memory usage.
class RenderPicture extends RenderBox {
  RenderPicture({
    PictureInfo picture,
    bool matchTextDirection: false,
    TextDirection textDirection,
    bool allowDrawingOutsideViewBox,
  })  : _picture = picture,
        _matchTextDirection = matchTextDirection,
        _textDirection = textDirection,
        _allowDrawingOutsideViewBox = allowDrawingOutsideViewBox;

  /// Whether to paint the picture in the direction of the [TextDirection].
  ///
  /// If this is true, then in [TextDirection.ltr] contexts, the picture will be
  /// drawn with its origin in the top left (the "normal" painting direction for
  /// pictures); and in [TextDirection.rtl] contexts, the picture will be drawn with
  /// a scaling factor of -1 in the horizontal direction so that the origin is
  /// in the top right.
  ///
  /// This is occasionally used with pictures in right-to-left environments, for
  /// pictures that were designed for left-to-right locales. Be careful, when
  /// using this, to not flip pictures with integral shadows, text, or other
  /// effects that will look incorrect when flipped.
  ///
  /// If this is set to true, [textDirection] must not be null.
  bool get matchTextDirection => _matchTextDirection;
  bool _matchTextDirection;
  set matchTextDirection(bool value) {
    assert(value != null);
    if (value == _matchTextDirection) {
      return;
    }
    _matchTextDirection = value;
    markNeedsPaint();
  }

  bool get _flipHorizontally =>
      _matchTextDirection && _textDirection == TextDirection.rtl;

  /// The text direction with which to resolve [alignment].
  ///
  /// This may be changed to null, but only after the [alignment] and
  /// [matchTextDirection] properties have been changed to values that do not
  /// depend on the direction.
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) {
      return;
    }
    _textDirection = value;
    markNeedsPaint();
  }

  PictureInfo _picture;
  PictureInfo get picture => _picture;
  set picture(PictureInfo val) {
    if (val == picture) {
      return;
    }
    _picture = val;
    markNeedsPaint();
  }

  bool _allowDrawingOutsideViewBox;
  bool get allowDrawingOutsideViewBox => _allowDrawingOutsideViewBox;
  set allowDrawingOutsideViewBox(bool val) {
    if (val == _allowDrawingOutsideViewBox) {
      return;
    }

    _allowDrawingOutsideViewBox = val;
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.smallest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (picture == null || size == null || size == Size.zero) {
      return;
    }
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);
    if (_flipHorizontally) {
      context.canvas.translate(offset.dx + size.width, 0.0);
      context.canvas.scale(-1.0, 1.0);
    }

    // this is sometimes useful for debugging, will remove
    // creates a red border around the drawing
    // context.canvas.drawRect(
    //     Offset.zero & size,
    //     new Paint()
    //       ..color = const Color(0xFFFA0000)
    //       ..style = PaintingStyle.stroke);

    scaleCanvasToViewBox(context.canvas, size, picture.viewBox);
    if (allowDrawingOutsideViewBox != true) {
      context.canvas.clipRect(picture.viewBox);
    }
    context.canvas.drawPicture(picture.picture);
    context.canvas.restore();
  }
}

void scaleCanvasToViewBox(Canvas canvas, Size desiredSize, Rect viewBox) {
  final double scale = math.min(
      desiredSize.width / viewBox.width, desiredSize.height / viewBox.height);
  final Offset shift = desiredSize / 2.0 - viewBox.size * scale / 2.0;
  canvas.translate(shift.dx, shift.dy);
  canvas.scale(scale, scale);
}
