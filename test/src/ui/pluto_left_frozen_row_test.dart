import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';
import 'package:rxdart/rxdart.dart';

import '../../helper/column_helper.dart';
import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';
import '../../mock/shared_mocks.mocks.dart';

void main() {
  late MockPlutoGridStateManager stateManager;
  PublishSubject<PlutoNotifierEvent> streamNotifier;
  List<PlutoColumn> columns;
  List<PlutoRow> rows;
  final resizingNotifier = ChangeNotifier();

  setUp(() {
    const configuration = PlutoGridConfiguration();
    stateManager = MockPlutoGridStateManager();
    streamNotifier = PublishSubject<PlutoNotifierEvent>();
    when(stateManager.streamNotifier).thenAnswer((_) => streamNotifier);
    when(stateManager.resizingChangeNotifier).thenReturn(resizingNotifier);
    when(stateManager.configuration).thenReturn(configuration);
    when(stateManager.style).thenReturn(configuration.style);
    when(stateManager.localeText).thenReturn(const PlutoGridLocaleText());
    when(stateManager.rowHeight).thenReturn(45);
    when(stateManager.isSelecting).thenReturn(true);
    when(stateManager.hasCurrentSelectingPosition).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);
    when(stateManager.selectingMode).thenReturn(PlutoGridSelectingMode.cell);
    when(stateManager.hasFocus).thenReturn(true);
    when(stateManager.canRowDrag).thenReturn(true);
    when(stateManager.showFrozenColumn).thenReturn(false);
    when(stateManager.enabledRowGroups).thenReturn(false);
    when(stateManager.rowGroupDelegate).thenReturn(null);
  });

  buildRowWidget({
    int rowIdx = 0,
    PlutoRowIndicatorCallback? rowIndicatorCallback,
    PlutoRowLeftFloatingWidgetCallback? leftFloatingCallback,
  }) {
    return PlutoWidgetTestHelper(
      'build row widget.',
      (tester) async {
        if (rowIndicatorCallback != null) {
          when(stateManager.rowIndicatorCallback)
              .thenAnswer((_) => rowIndicatorCallback);
        }
        if (leftFloatingCallback != null) {
          when(stateManager.rowLeftFloatingWidgetCallback)
              .thenAnswer((_) => leftFloatingCallback);
        }

        columns = ColumnHelper.textColumn('header', count: 3);
        rows = RowHelper.count(10, columns);

        when(stateManager.columns).thenReturn(columns);

        final row = rows[rowIdx];

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: FrozenRow(
                rowIdx: rowIdx,
                row: row,
                columns: columns,
                stateManager: stateManager,
              ),
            ),
          ),
        );
      },
    );
  }

  buildRowWidget(
    leftFloatingCallback: (_) => Container(
      color: Colors.yellow,
    ),
  ).test(
    'rowLeftFloatingWidgetCallback defined',
    (tester) async {
      final rowFloatingWidget =
          find.byType(Container).last.evaluate().last.widget as Container;

      expect(
        rowFloatingWidget.color,
        Colors.yellow,
      );
    },
  );

  buildRowWidget(
    rowIndicatorCallback: (_) => Container(
      color: Colors.red,
    ),
  ).test(
    'rowIndicatorCallback defined',
    (tester) async {
      final rowIndicatorWidget =
          find.byType(Container).first.evaluate().first.widget as Container;

      expect(
        rowIndicatorWidget.color,
        Colors.red,
      );
    },
  );
}
