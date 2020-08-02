import 'package:flutter/material.dart';

class Annotation extends Comparable<Annotation> {
  Annotation({@required this.range, this.style});

  final TextRange range;
  final TextStyle style;

  @override
  int compareTo(Annotation other) {
    return range.start.compareTo(other.range.start);
  }

  @override
  String toString() {
    return 'Annotation(range:$range, style:$style)';
  }
}

class RegexAnnotation {
  RegexAnnotation({@required this.regex, this.style});

  final RegExp regex;
  final TextStyle style;

  @override
  String toString() {
    return 'RegexAnnotation{regex: $regex, style: $style}';
  }
}

class ColorizedTextForm extends EditableText {
  ColorizedTextForm({
    Key key,
    int maxLines = 1,
    FocusNode focusNode,
    TextEditingController controller,
    TextStyle style,
    ValueChanged<String> onChanged,
    ValueChanged<String> onSubmitted,
    Color cursorColor,
    Color selectionColor,
    TextSelectionControls selectionControls,
    this.annotations,
    this.regexAnnotation,
  }) : super(
          key: key,
          focusNode: focusNode,
          controller: controller,
          cursorColor: cursorColor,
          backgroundCursorColor: Colors.black,
          style: style,
          keyboardType: TextInputType.text,
          autocorrect: false,
          autofocus: false,
          maxLines: maxLines,
          selectionColor: selectionColor,
          selectionControls: selectionControls,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        );

  final List<Annotation> annotations;
  final RegexAnnotation regexAnnotation;

  @override
  _ColorizedTextFormState createState() => new _ColorizedTextFormState();
}

class _ColorizedTextFormState extends EditableTextState {
  @override
  ColorizedTextForm get widget => super.widget;

  List<Annotation> getRanges(List<Annotation> source) {
    source.sort();
    var result = new List<Annotation>();
    Annotation prev;
    for (Annotation item in source) {
      if (prev == null) {
        // First item, check if we need one before it.
        if (item.range.start > 0) {
          result.add(new Annotation(
            range: TextRange(start: 0, end: item.range.start),
          ));
        }
        result.add(item);
        prev = item;
        continue;
      } else {
        // Consequent item, check if there is a gap between.
        if (prev.range.end > item.range.start) {
          // Invalid ranges
          throw new StateError(
              'Invalid (intersecting) ranges for annotated field');
        } else if (prev.range.end < item.range.start) {
          result.add(Annotation(
            range: TextRange(start: prev.range.end, end: item.range.start),
          ));
        }
        // Also add current annotation
        result.add(item);
        prev = item;
      }
    }
    // Also check for trailing range
    final String text = textEditingValue.text;
    if (result.last.range.end < text.length) {
      result.add(Annotation(
        range: TextRange(start: result.last.range.end, end: text.length),
      ));
    }
    return result;
  }

  List<TextSpan> getRangesWithRegex(RegexAnnotation annotation, String text) {
    Iterable<RegExpMatch> matches = annotation.regex.allMatches(text);
    var children = <TextSpan>[];
    int currentPosition = 0;
    int length = text.length;
    if (matches.length == 0) {
      return [TextSpan(style: null, text: text)];
    }
    for (RegExpMatch match in matches) {
      if (match.start - currentPosition > 0) {
        children.add(
          TextSpan(
              style: null,
              text: TextRange(start: currentPosition, end: match.start)
                  .textInside(text)),
        );
      }
      children.add(
        TextSpan(
            style: widget.regexAnnotation.style,
            text:
                TextRange(start: match.start, end: match.end).textInside(text)),
      );
      currentPosition = match.end;
    }
    if (length - currentPosition > 0) {
      children.add(
        TextSpan(
            style: null,
            text: TextRange(start: currentPosition, end: length)
                .textInside(text)),
      );
    }
    return children;
  }

  @override
  TextSpan buildTextSpan() {
    final String text = textEditingValue.text;
    int textLength = text.length;
    if (widget.annotations != null && textLength > 0) {
      var items = getRanges(widget.annotations);
      var children = <TextSpan>[];
      for (var item in items) {
        if (item.range.end < textLength) {
          children.add(
            TextSpan(style: item.style, text: item.range.textInside(text)),
          );
        } else if (item.range.start <= textLength) {
          children.add(
            TextSpan(
                style: item.style,
                text: TextRange(start: item.range.start, end: text.length)
                    .textInside(text)),
          );
        }
      }
      return new TextSpan(style: widget.style, children: children);
    }

    if (widget.regexAnnotation != null) {
      return new TextSpan(
          style: widget.style,
          children: getRangesWithRegex(widget.regexAnnotation, text));
    }

    return new TextSpan(style: widget.style, text: text);
  }
}
