import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class RichTextEditorWidget extends StatefulWidget {
  final String initialContent;
  final Function(String) onContentChanged;
  final bool readOnly;

  const RichTextEditorWidget({
    super.key,
    required this.initialContent,
    required this.onContentChanged,
    this.readOnly = false,
  });

  @override
  State<RichTextEditorWidget> createState() => _RichTextEditorWidgetState();
}

class _RichTextEditorWidgetState extends State<RichTextEditorWidget> {
  late TextEditingController _controller;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  void didUpdateWidget(RichTextEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialContent != oldWidget.initialContent) {
      _controller.text = widget.initialContent;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AirMenuColors.primary.shade3, width: 1),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar
          if (!widget.readOnly)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AirMenuColors.primary.shade7,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AirMenuColors.primary.shade3,
                    width: 1,
                  ),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  final toolbarButtons = [
                    Text(
                      'Normal',
                      style: AirMenuTextStyle.small.copyWith(
                        color: AirMenuColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_drop_down, size: 20),
                    const SizedBox(width: 24),
                    _buildToolbarButton(
                      Icons.format_bold,
                      'Bold',
                      () => _insertHtmlTag('<strong>', '</strong>'),
                    ),
                    _buildToolbarButton(
                      Icons.format_italic,
                      'Italic',
                      () => _insertHtmlTag('<em>', '</em>'),
                    ),
                    _buildToolbarButton(
                      Icons.format_underlined,
                      'Underline',
                      () => _insertHtmlTag('<u>', '</u>'),
                    ),
                    _buildToolbarButton(
                      Icons.format_strikethrough,
                      'Strikethrough',
                      () => _insertHtmlTag('<s>', '</s>'),
                    ),
                    const SizedBox(width: 16),
                    _buildToolbarButton(
                      Icons.format_list_bulleted,
                      'Bullet List',
                      () => _insertList(false),
                    ),
                    _buildToolbarButton(
                      Icons.format_list_numbered,
                      'Numbered List',
                      () => _insertList(true),
                    ),
                    const SizedBox(width: 16),
                    _buildToolbarButton(
                      Icons.format_align_left,
                      'Align Left',
                      () => _insertHtmlTag(
                        '<div style="text-align: left;">',
                        '</div>',
                      ),
                    ),
                    _buildToolbarButton(
                      Icons.format_align_center,
                      'Align Center',
                      () => _insertHtmlTag(
                        '<div style="text-align: center;">',
                        '</div>',
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildToolbarButton(
                      Icons.format_color_text,
                      'Text Color',
                      () => _insertHtmlTag(
                        '<span style="color: #FF0000;">',
                        '</span>',
                      ),
                    ),
                    _buildToolbarButton(
                      Icons.format_color_fill,
                      'Background',
                      () => _insertHtmlTag(
                        '<span style="background-color: #FFFF00;">',
                        '</span>',
                      ),
                    ),
                    _buildToolbarButton(Icons.link, 'Link', _insertLink),
                    _buildToolbarButton(
                      Icons.code,
                      'Code',
                      () => _insertHtmlTag('<code>', '</code>'),
                    ),
                  ];

                  if (isMobile) {
                    // Mobile: Scrollable toolbar
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...toolbarButtons,
                          const SizedBox(width: 16),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _showPreview = !_showPreview;
                              });
                            },
                            icon: Icon(
                              _showPreview ? Icons.edit : Icons.visibility,
                              size: 18,
                            ),
                            label: Text(_showPreview ? 'Edit' : 'Preview'),
                            style: TextButton.styleFrom(
                              foregroundColor: AirMenuColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Desktop/Tablet: Fixed layout with Spacer
                    return Row(
                      children: [
                        ...toolbarButtons,
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showPreview = !_showPreview;
                            });
                          },
                          icon: Icon(
                            _showPreview ? Icons.edit : Icons.visibility,
                            size: 18,
                          ),
                          label: Text(_showPreview ? 'Edit' : 'Preview'),
                          style: TextButton.styleFrom(
                            foregroundColor: AirMenuColors.secondary,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          // Content Area
          Expanded(
            child: _showPreview
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Html(
                      data: _controller.text,
                      style: {
                        "body": Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                        ),
                      },
                    ),
                  )
                : TextField(
                    controller: _controller,
                    maxLines: null,
                    readOnly: widget.readOnly,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(24),
                      hintText: 'Enter content here...',
                    ),
                    style: AirMenuTextStyle.normal,
                    onChanged: widget.onContentChanged,
                  ),
          ),
        ],
      ),
    );
  }

  void _insertHtmlTag(String openTag, String closeTag) {
    final text = _controller.text;
    final selection = _controller.selection;

    if (selection.baseOffset == -1) {
      // No selection, insert at end
      final newText = text + openTag + closeTag;
      _controller.text = newText;
      _controller.selection = TextSelection.collapsed(
        offset: text.length + openTag.length,
      );
    } else {
      // Wrap selected text
      final selectedText = selection.textInside(text);
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$openTag$selectedText$closeTag',
      );
      _controller.text = newText;
      _controller.selection = TextSelection.collapsed(
        offset:
            selection.start +
            openTag.length +
            selectedText.length +
            closeTag.length,
      );
    }
    widget.onContentChanged(_controller.text);
  }

  void _insertList(bool ordered) {
    final text = _controller.text;
    final selection = _controller.selection;
    final selectedText = selection.baseOffset == -1
        ? ''
        : selection.textInside(text);

    final listTag = ordered ? 'ol' : 'ul';
    final listItem = selectedText.isEmpty
        ? '<li>List item</li>'
        : '<li>$selectedText</li>';
    final newContent = '<$listTag>\n  $listItem\n</$listTag>';

    if (selection.baseOffset == -1) {
      _controller.text = text + '\n' + newContent;
    } else {
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        newContent,
      );
      _controller.text = newText;
    }
    widget.onContentChanged(_controller.text);
  }

  void _insertLink() {
    final text = _controller.text;
    final selection = _controller.selection;
    final selectedText = selection.baseOffset == -1
        ? 'Link text'
        : selection.textInside(text);

    final linkHtml = '<a href="https://example.com">$selectedText</a>';

    if (selection.baseOffset == -1) {
      _controller.text = text + linkHtml;
    } else {
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        linkHtml,
      );
      _controller.text = newText;
    }
    widget.onContentChanged(_controller.text);
  }

  Widget _buildToolbarButton(
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: AirMenuColors.secondary),
        ),
      ),
    );
  }
}
