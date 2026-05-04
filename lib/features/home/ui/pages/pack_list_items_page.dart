import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/pack_list_provider.dart';
import 'primary_create_list_page.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_buttons.dart';
import 'package:tawakad_app/core/widgets/field_card.dart';
import 'package:tawakad_app/core/widgets/glass_elements/glass_back_button.dart';
import 'package:tawakad_app/core/widgets/cards/circle_btn.dart';

class PackListItemsPage extends StatefulWidget {
  final String listId;
  const PackListItemsPage({super.key, required this.listId});

  @override
  State<PackListItemsPage> createState() => _PackListItemsPageState();
}

class _PackListItemsPageState extends State<PackListItemsPage> {
  bool _isEditing = false;
  int? _editingIndex;
  final TextEditingController _editController = TextEditingController();
  final FocusNode _editFocus = FocusNode();

  bool _isAdding = false;
  final TextEditingController _addController = TextEditingController();
  final FocusNode _addFocus = FocusNode();

  @override
  void dispose() {
    _editController.dispose();
    _editFocus.dispose();
    _addController.dispose();
    _addFocus.dispose();
    super.dispose();
  }

  void _submitEdit(String listId, int index) {
    final text = _editController.text.trim();
    if (text.isNotEmpty) {
      context.read<PackListProvider>().renameItem(listId, index, text);
    }
    setState(() => _editingIndex = null);
  }

  void _submitAdd(String listId) {
    final text = _addController.text.trim();
    if (text.isNotEmpty) {
      context.read<PackListProvider>().addItem(listId, text);
    }
    _addController.clear();
    setState(() => _isAdding = false);
  }

  void _startAdding() {
    _addController.clear();
    setState(() => _isAdding = true);
    Future.delayed(const Duration(milliseconds: 50), _addFocus.requestFocus);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final list = context
        .watch<PackListProvider>()
        .lists
        .firstWhere((l) => l.id == widget.listId);

    final accentColor = list.color;
    final items = list.items;
    final checkedIndices = list.checkedIndices;

    final textPrimary = theme.colorScheme.onSurface;
    final textMuted = textPrimary.withOpacity(0.38);
    final dividerColor =
        isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        toolbarHeight: kToolbarHeight + 40,
        actions: [
          const SizedBox(width: 24),
          const GlassBackButton(),
          const SizedBox(width: 16),
          Text(list.title, style: theme.textTheme.bodyLarge),
          const Spacer(),
          AppLiquidButtons.iconWithLabel(
            icon: _isEditing ? Icons.check_rounded : Icons.edit_outlined,
            label: 'تعديل الأغراض',
            iconColor: _isEditing ? accentColor : null,
            iconSize: 18,
            onPressed: () => setState(() {
              _isEditing = !_isEditing;
              _editingIndex = null;
              _isAdding = false;
            }),
          ),
          const SizedBox(width: 8),
          AppLiquidButtons.iconWithLabel(
            icon: Icons.tune_rounded,
            label: 'تعديل القائمة',
            iconSize: 18,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PrimaryCreateListPage(existing: list),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: items.isEmpty && !_isAdding
                  ? Center(
                      child: Text(
                        'لا توجد أغراض بعد',
                        style: TextStyle(color: textMuted, fontSize: 16),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.only(top: 16),
                      children: [
                        FieldCard(
                          gap: 0,
                          children: [
                            ...List.generate(items.length, (i) {
                              final item = items[i];
                              final isChecked = checkedIndices.contains(i);
                              final isEditingThis =
                                  _isEditing && _editingIndex == i;

                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 12),
                                    child: Row(
                                      children: [
                                        if (_isEditing)
                                          GestureDetector(
                                            onTap: () {
                                              context
                                                  .read<PackListProvider>()
                                                  .removeItemAt(
                                                      widget.listId, i);
                                              setState(() {
                                                if (_editingIndex == i) {
                                                  _editingIndex = null;
                                                }
                                              });
                                            },
                                            child: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Colors.redAccent,
                                              size: 22,
                                            ),
                                          )
                                        else
                                          GestureDetector(
                                            onTap: () => context
                                                .read<PackListProvider>()
                                                .toggleItemChecked(
                                                    widget.listId, i),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: isChecked
                                                    ? accentColor
                                                    : Colors.transparent,
                                                border: Border.all(
                                                  color: isChecked
                                                      ? accentColor
                                                      : const Color(0xFFB0B0B8),
                                                  width: 1.8,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: isChecked
                                                  ? const Icon(
                                                      Icons.check_rounded,
                                                      color: Colors.white,
                                                      size: 15,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: isEditingThis
                                              ? TextField(
                                                  controller: _editController,
                                                  focusNode: _editFocus,
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  textAlign: TextAlign.right,
                                                  autofocus: true,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: textPrimary,
                                                    decoration: isChecked
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : TextDecoration.none,
                                                  ),
                                                  decoration:
                                                      const InputDecoration(
                                                    border: InputBorder.none,
                                                    isDense: true,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                  ),
                                                  onSubmitted: (_) =>
                                                      _submitEdit(
                                                          widget.listId, i),
                                                )
                                              : GestureDetector(
                                                  onTap: _isEditing
                                                      ? () {
                                                          _editController.text =
                                                              item;
                                                          setState(() =>
                                                              _editingIndex =
                                                                  i);
                                                          Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    50),
                                                            _editFocus
                                                                .requestFocus,
                                                          );
                                                        }
                                                      : null,
                                                  child: Text(
                                                    item,
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isChecked
                                                          ? textMuted
                                                          : textPrimary,
                                                      decoration: isChecked
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : TextDecoration.none,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (i < items.length - 1 || _isAdding)
                                    Divider(
                                      height: 1,
                                      thickness: 0.5,
                                      color: dividerColor,
                                      indent: 18,
                                      endIndent: 18,
                                    ),
                                ],
                              );
                            }),
                            if (_isAdding)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                child: Row(
                                  children: [
                                    CircleBtn(
                                      icon: Icons.check_rounded,
                                      iconColor: Colors.white,
                                      bg: accentColor,
                                      onTap: () => _submitAdd(widget.listId),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: _addController,
                                        focusNode: _addFocus,
                                        textDirection: TextDirection.rtl,
                                        textAlign: TextAlign.right,
                                        autofocus: true,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: textPrimary,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'اسم الغرض',
                                          hintTextDirection: TextDirection.rtl,
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          hintStyle: TextStyle(
                                            color: textMuted,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        onSubmitted: (_) =>
                                            _submitAdd(widget.listId),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
            ),

            // ── Bottom: إضافة غرض — natural size, right aligned ────────────
            if (!_isAdding)
              Padding(
                padding: const EdgeInsets.only(bottom: 36, top: 16),
                child: Row(
                  children: [
                    const Spacer(),
                    AppLiquidButtons.iconWithLabel(
                      icon: Icons.add_rounded,
                      label: 'إضافة غرض',
                      iconSize: 20,
                      onPressed: _startAdding,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
