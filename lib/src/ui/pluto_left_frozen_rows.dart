import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'ui.dart';

class PlutoLeftFrozenRows extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  const PlutoLeftFrozenRows(
    this.stateManager, {
    super.key,
  });

  @override
  PlutoLeftFrozenRowsState createState() => PlutoLeftFrozenRowsState();
}

class PlutoLeftFrozenRowsState
    extends PlutoStateWithChange<PlutoLeftFrozenRows> {
  List<PlutoColumn> _columns = [];

  List<PlutoRow> _rows = [];

  late final ScrollController _scroll;

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    _scroll = stateManager.scroll.vertical!.addAndGet();

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void dispose() {
    _scroll.dispose();

    super.dispose();
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    forceUpdate();

    _columns = stateManager.leftFrozenColumns;

    _rows = stateManager.refRows;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scroll,
      scrollDirection: Axis.vertical,
      physics: const ClampingScrollPhysics(),
      itemCount: _rows.length,
      itemExtent: stateManager.rowTotalHeight,
      itemBuilder: (ctx, i) {
        return FrozenRow(
          key: ValueKey('left_frozen_row_${_rows[i].key}'),
          rowIdx: i,
          row: _rows[i],
          columns: _columns,
          stateManager: stateManager,
        );
      },
    );
  }
}

class FrozenRow extends StatefulWidget {
  final int rowIdx;

  final PlutoRow row;

  final List<PlutoColumn> columns;

  final PlutoGridStateManager stateManager;

  final bool visibilityLayout;

  const FrozenRow({
    required this.rowIdx,
    required this.row,
    required this.columns,
    required this.stateManager,
    this.visibilityLayout = false,
    super.key,
  });

  @override
  State<FrozenRow> createState() => _FrozenRowState();
}

class _FrozenRowState extends State<FrozenRow> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _leftFloatingEntry;

  _showOverlay() {
    if (_leftFloatingEntry != null) {
      _leftFloatingEntry?.remove();
      _leftFloatingEntry = null;
    }

    Widget? floatingWidget =
        widget.stateManager.rowLeftFloatingWidgetCallback?.call(
      PlutoRowContext(
        row: widget.row,
        rowIdx: widget.rowIdx,
        stateManager: widget.stateManager,
      ),
    );

    if (floatingWidget == null) return;

    _leftFloatingEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          child: floatingWidget,
        ),
      ),
    );

    if (_leftFloatingEntry != null) {
      return Overlay.of(context).insert(_leftFloatingEntry!);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_leftFloatingEntry != null) {
      _leftFloatingEntry?.remove();
      _leftFloatingEntry = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _showOverlay());

    return CompositedTransformTarget(
      link: _layerLink,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          PlutoBaseRow(
            key: widget.key,
            rowIdx: widget.rowIdx,
            row: widget.row,
            columns: widget.columns,
            stateManager: widget.stateManager,
          ),
          widget.stateManager.rowIndicatorCallback?.call(
                PlutoRowContext(
                  rowIdx: widget.rowIdx,
                  row: widget.row,
                  stateManager: widget.stateManager,
                ),
              ) ??
              Container(),
        ],
      ),
    );
  }
}
