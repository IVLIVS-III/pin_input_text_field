import 'dart:ui';

import 'package:pin_input_text_field/src/cursor/pin_cursor.dart';

abstract class ICursorPaint {
  void drawCursor(Canvas canvas, Size size, Rect rect, Cursor cursor,
      [Offset? offset]);
}

mixin CursorPaint implements ICursorPaint {
  /* Try and fix [Cursor] overriding [HintText] due to them being
   * displayed in the same location on screen (both entered in the box).
   * Idea:
   *   - [Cursor] and [HintText] should coexist and be displayed at the
   *     same time
   *   - for visual integrity, entering a character and changing visual
   *     focus to the next pin field should lead to only minimal changes
   *     -> [HintText] should not have a different position with/without
   *        [Cursor]
   *     -> [HintText] should be displayed in the center of the box
   *     -> [Cursor] should not be displayed in the center of the box if a
   *        [HintText] is also present
   *     -> [Cursor] should be displayed in front of [HintText] or behind
   *   - [Cursor] typically is (on input fields with left-justified text) after
   *     already typed characters
   *   - [HintText] typically is displayed only when no characters have been
   *     entered yet
   *     -> [Cursor] should be displayed in front of the [HintText] at least
   *        with TextDirection.LTR
   *   - for minimal disruption in the existing codebase, this fix proposes to
   *     add an optional positional or named Parameter [Offset] offset with a
   *     default value of Offset.zero
   *   - the offset would be added to the location given by rect prior to
   *     drawing
   *   - this function can then be called offsetting the [Cursor] to be drawn
   *     to the left or right of [HintText]
   */
  @override
  void drawCursor(Canvas canvas, Size size, Rect rect, Cursor cursor,
      [Offset? offset, TextDirection textDirection = TextDirection.ltr]) {
    Offset effectiveOffset = Offset.zero;
    if (offset != null) {
      effectiveOffset = offset + Offset(cursor.width, 0);
    }
    if (textDirection == TextDirection.rtl) {
      effectiveOffset *= -1;
    }

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..color = cursor.color
      ..strokeWidth = cursor.width;
    double height = cursor.height ?? size.height / 3;

    RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        rect.center.dx - cursor.width / 2 - effectiveOffset.dx,
        rect.center.dy - height / 2 - effectiveOffset.dy,
        cursor.width,
        height,
      ),
      cursor.radius,
    );
    canvas.drawRRect(rRect, paint);
  }
}
