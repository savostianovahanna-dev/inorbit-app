import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inorbit/core/theme/app_text_styles.dart';
import 'package:inorbit/domain/entities/friend.dart';
import 'package:inorbit/domain/entities/moment.dart';
import 'package:share_plus/share_plus.dart';

// ─── Layout constants ─────────────────────────────────────────────────────────

const _kGap = 3.0; // gap between cells
const _kRowMargin = 20.0; // vertical gap between visual rows (year view)
const _kStarSize = 6.0; // star drawing diameter
const _kLabelH = 16.0; // height reserved for month labels above each row

const _kStarColor = Color(0xFFC8B8FF);
const _kGlowColor = Color(0x25C8B8FF);
const _kLineColor = Color(0x8CC8B8FF);
const _kEmptyColor = Color(0x14FFFFFF);
const _kDarkBg = Color(0xFF0D1117);

// ─── Background options ───────────────────────────────────────────────────────

enum _ConstellationBg { darkBlue, dark222, photo1, photo2 }

const _kBgLabel = {
  _ConstellationBg.darkBlue: 'Dark blue',
  _ConstellationBg.dark222: 'Black',
  _ConstellationBg.photo1: 'Space 1',
  _ConstellationBg.photo2: 'Space 2',
};

BoxDecoration _bgDecoration(_ConstellationBg bg, {double borderRadius = 16}) {
  final radius = BorderRadius.circular(borderRadius);
  switch (bg) {
    case _ConstellationBg.darkBlue:
      return BoxDecoration(color: _kDarkBg, borderRadius: radius);
    case _ConstellationBg.dark222:
      return BoxDecoration(color: const Color(0xFF222222), borderRadius: radius);
    case _ConstellationBg.photo1:
    case _ConstellationBg.photo2:
      return BoxDecoration(
        borderRadius: radius,
        image: const DecorationImage(
          image: AssetImage('assets/images/home.png'),
          fit: BoxFit.cover,
        ),
      );
  }
}

const _kMonthAbbr = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

// ─── Internal data classes ────────────────────────────────────────────────────

class _CellInfo {
  const _CellInfo({
    required this.rowIndex,
    required this.colIndex,
    required this.dayIndex,
    required this.starIndex,
  });

  final int rowIndex; // which visual row (0 = top)
  final int colIndex; // 0–(numCols-1) within that row
  final int dayIndex; // 0–6  (Mon=0 … Sun=6)
  final int starIndex; // sequential across all active cells (for stagger)
}

class _GridRow {
  const _GridRow({
    required this.rowIndex,
    required this.rowStartDate,
    required this.monthLabels,
  });

  final int rowIndex;
  final DateTime rowStartDate;
  final Map<int, String> monthLabels; // colIndex → 'Jan' etc.
}

class _GridData {
  const _GridData({
    required this.rows,
    required this.activeCells,
    required this.numCols,
  });

  final List<_GridRow> rows;
  final List<_CellInfo> activeCells; // chronological order
  final int numCols;
}

// ─── Grid builders ────────────────────────────────────────────────────────────

/// Returns the Monday on or before [date].
DateTime _mondayOf(DateTime date) =>
    date.subtract(Duration(days: date.weekday - 1));

/// Returns the last day of [month] in [year].
DateTime _lastDayOf(int year, int month) => DateTime(year, month + 1, 0);

/// Builds a grid for the 3 calendar months ending with today's month.
/// Shows all weeks of each month (including future weeks in the current month).
_GridData _build3MonthGrid(Map<DateTime, int> activityByDay) {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);

  // Start month = 2 months before current (handles Jan/Feb wrap)
  final int rawStart = todayDate.month - 2;
  final int startYear = rawStart <= 0 ? todayDate.year - 1 : todayDate.year;
  final int startMonth = rawStart <= 0 ? rawStart + 12 : rawStart;
  final int endMonth = todayDate.month;

  final startMonday = _mondayOf(DateTime(startYear, startMonth, 1));
  final endMonday = _mondayOf(_lastDayOf(todayDate.year, endMonth));
  final numCols = (endMonday.difference(startMonday).inDays ~/ 7) + 1;

  // Only label the 3 target months (prevents "next month" label on last col)
  final targetMonths = <int>{};
  for (int i = 0; i < 3; i++) {
    int m = startMonth + i;
    if (m > 12) m -= 12;
    targetMonths.add(m);
  }

  return _buildRows(
    rowStartDates: [startMonday],
    numCols: numCols,
    activityByDay: activityByDay,
    todayDate: todayDate,
    labelMonthSets: [targetMonths],
  );
}

/// Builds a grid with 2 rows — Q1 (Jan–Mar) and Q2 (Apr–Jun) — used for capture.
_GridData _buildH1Grid(Map<DateTime, int> activityByDay) {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final year = todayDate.year;

  const qStarts = [1, 4];

  final rowStartDates = <DateTime>[];
  final labelMonthSets = <Set<int>>[];
  int maxNumCols = 0;

  for (final sm in qStarts) {
    final em = sm + 2;
    final startMonday = _mondayOf(DateTime(year, sm, 1));
    final endMonday = _mondayOf(_lastDayOf(year, em));
    final numCols = (endMonday.difference(startMonday).inDays ~/ 7) + 1;

    rowStartDates.add(startMonday);
    labelMonthSets.add({sm, sm + 1, sm + 2});
    if (numCols > maxNumCols) maxNumCols = numCols;
  }

  return _buildRows(
    rowStartDates: rowStartDates,
    numCols: maxNumCols,
    activityByDay: activityByDay,
    todayDate: todayDate,
    labelMonthSets: labelMonthSets,
  );
}

/// Builds a year grid with 4 rows — one per calendar quarter:
/// Q1 = Jan–Mar, Q2 = Apr–Jun, Q3 = Jul–Sep, Q4 = Oct–Dec.
_GridData _buildYearGrid(Map<DateTime, int> activityByDay) {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final year = todayDate.year;

  // Quarter start months
  const qStarts = [1, 4, 7, 10];

  final rowStartDates = <DateTime>[];
  final labelMonthSets = <Set<int>>[];
  int maxNumCols = 0;

  for (final sm in qStarts) {
    final em = sm + 2; // last month of quarter (e.g. Mar=3, Jun=6…)
    final startMonday = _mondayOf(DateTime(year, sm, 1));
    final endMonday = _mondayOf(_lastDayOf(year, em));
    final numCols = (endMonday.difference(startMonday).inDays ~/ 7) + 1;

    rowStartDates.add(startMonday);
    labelMonthSets.add({sm, sm + 1, sm + 2});
    if (numCols > maxNumCols) maxNumCols = numCols;
  }

  return _buildRows(
    rowStartDates: rowStartDates,
    numCols: maxNumCols,
    activityByDay: activityByDay,
    todayDate: todayDate,
    labelMonthSets: labelMonthSets,
  );
}

/// Core builder. Each element of [rowStartDates] is the Monday that starts
/// that visual row. All rows use the same [numCols] for a uniform grid.
/// [labelMonthSets] restricts which months get labels per row (prevents
/// "spill" labels from adjacent months at row edges).
_GridData _buildRows({
  required List<DateTime> rowStartDates,
  required int numCols,
  required Map<DateTime, int> activityByDay,
  required DateTime todayDate,
  List<Set<int>>? labelMonthSets,
}) {
  final rows = <_GridRow>[];
  final activeCells = <_CellInfo>[];
  int starIndex = 0;

  for (int ri = 0; ri < rowStartDates.length; ri++) {
    final rowStart = rowStartDates[ri];
    final targetMonths = labelMonthSets?[ri];
    final monthLabels = <int, String>{};
    int? prevMonth;

    // Use Sunday's month so cross-month weeks label the later month.
    // Only emit a label if it belongs to the target set for this row.
    for (int col = 0; col < numCols; col++) {
      final colSunday = rowStart.add(Duration(days: col * 7 + 6));
      final month = colSunday.month;
      if (month != prevMonth &&
          (targetMonths == null || targetMonths.contains(month))) {
        monthLabels[col] = _kMonthAbbr[month - 1];
        prevMonth = month;
      }
    }

    rows.add(
      _GridRow(rowIndex: ri, rowStartDate: rowStart, monthLabels: monthLabels),
    );

    for (int col = 0; col < numCols; col++) {
      for (int day = 0; day < 7; day++) {
        final cellDate = rowStart.add(Duration(days: col * 7 + day));
        if (cellDate.isAfter(todayDate)) continue;
        final count = activityByDay[cellDate] ?? 0;
        if (count > 0) {
          activeCells.add(
            _CellInfo(
              rowIndex: ri,
              colIndex: col,
              dayIndex: day,
              starIndex: starIndex++,
            ),
          );
        }
      }
    }
  }

  return _GridData(rows: rows, activeCells: activeCells, numCols: numCols);
}

// ─── Public widget ────────────────────────────────────────────────────────────

class ConstellationActivitySection extends StatefulWidget {
  const ConstellationActivitySection({
    super.key,
    required this.activityByDay,
    required this.momentsByDay,
    required this.friends,
  });

  final Map<DateTime, int> activityByDay;
  final Map<DateTime, List<Moment>> momentsByDay;
  final List<Friend> friends;

  @override
  State<ConstellationActivitySection> createState() =>
      _ConstellationActivitySectionState();
}

class _ConstellationActivitySectionState
    extends State<ConstellationActivitySection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;
  bool _expanded = true; // start in expanded (year) view
  bool _isCapturing = false;
  _GridData? _captureGridData;
  _ConstellationBg _captureBg = _ConstellationBg.darkBlue;

  final _captureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _pulseAnim = _pulseController;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<Uint8List?> _capture(_ConstellationBg bg) async {
    setState(() {
      _captureGridData = _buildH1Grid(widget.activityByDay);
      _captureBg = bg;
      _isCapturing = true;
    });
    await WidgetsBinding.instance.endOfFrame;

    final boundary =
        _captureKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    Uint8List? bytes;
    if (boundary != null) {
      final image = await boundary.toImage(pixelRatio: 3.0);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      bytes = data?.buffer.asUint8List();
    }

    setState(() {
      _isCapturing = false;
      _captureGridData = null;
      _captureBg = _ConstellationBg.darkBlue;
    });
    return bytes;
  }

  Future<_ConstellationBg?> _showBgPicker() {
    return showModalBottomSheet<_ConstellationBg>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => _BgPickerSheet(
            activityByDay: widget.activityByDay,
            momentsByDay: widget.momentsByDay,
            friends: widget.friends,
          ),
    );
  }

  Future<void> _save() async {
    final bg = await _showBgPicker();
    if (bg == null) return;
    final bytes = await _capture(bg);
    if (bytes == null) return;
    await Gal.putImageBytes(bytes);
  }

  Future<void> _share() async {
    final bg = await _showBgPicker();
    if (bg == null) return;
    final bytes = await _capture(bg);
    if (bytes == null) return;
    await Share.shareXFiles([
      XFile.fromData(
        bytes,
        mimeType: 'image/png',
        name: 'inorbit_activity.png',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final gridData =
        _expanded
            ? _buildYearGrid(widget.activityByDay)
            : _build3MonthGrid(widget.activityByDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ConstellationHeader(
          expanded: _expanded,
          onToggle: () => setState(() => _expanded = !_expanded),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _kDarkBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Only this portion is captured as a photo
                RepaintBoundary(
                  key: _captureKey,
                  child: Container(
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: _isCapturing
                        ? _bgDecoration(_captureBg)
                        : const BoxDecoration(
                            color: _kDarkBg,
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                    padding: const EdgeInsets.all(12),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                      child: _ConstellationGrid(
                        key: ValueKey(_expanded),
                        gridData: _captureGridData ?? gridData,
                        pulseAnim: _pulseAnim,
                        captureMode: _isCapturing,
                        momentsByDay: widget.momentsByDay,
                        friends: widget.friends,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: _share,
                      child: SvgPicture.asset(
                        'assets/icons/share.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                    const SizedBox(width: 18),
                    GestureDetector(
                      onTap: _save,
                      child: SvgPicture.asset(
                        'assets/icons/save.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _ConstellationHeader extends StatelessWidget {
  const _ConstellationHeader({required this.expanded, required this.onToggle});

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Opacity(
          opacity: 0.75,
          child: Text('Activity', style: AppTextStyles.bodyMedium16),
        ),
        const Spacer(),
        // GestureDetector(
        //   onTap: onToggle,
        //   child: AnimatedRotation(
        //     turns: expanded ? 0.5 : 0.0,
        //     duration: const Duration(milliseconds: 300),
        //     curve: Curves.easeInOut,
        //     child: const Icon(
        //       Icons.keyboard_arrow_down_rounded,
        //       color: Color(0x99C8B8FF),
        //       size: 20,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

// ─── Grid ─────────────────────────────────────────────────────────────────────

class _ConstellationGrid extends StatelessWidget {
  const _ConstellationGrid({
    super.key,
    required this.gridData,
    required this.pulseAnim,
    this.captureMode = false,
    required this.momentsByDay,
    required this.friends,
  });

  final _GridData gridData;
  final Animation<double> pulseAnim;

  /// When true, empty cells are transparent — used during screenshot capture.
  final bool captureMode;
  final Map<DateTime, List<Moment>> momentsByDay;
  final List<Friend> friends;

  @override
  Widget build(BuildContext context) {
    final numVisualRows = gridData.rows.length;
    final numCols = gridData.numCols;

    final activeMap = <String, _CellInfo>{
      for (final c in gridData.activeCells)
        '${c.rowIndex}-${c.colIndex}-${c.dayIndex}': c,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final availW = constraints.maxWidth;
        final stride = (availW + _kGap) / numCols;
        final cellSize = stride - _kGap;
        final colH = 7 * cellSize + 6 * _kGap;
        final totalH =
            numVisualRows * (_kLabelH + colH) +
            (numVisualRows - 1) * _kRowMargin;

        final cells = <Widget>[];

        for (final row in gridData.rows) {
          final rowTopY = row.rowIndex * (_kLabelH + colH + _kRowMargin);

          // Month labels (hidden during capture)
          if (!captureMode) {
            for (final entry in row.monthLabels.entries) {
              cells.add(
                Positioned(
                  left: entry.key * stride,
                  top: rowTopY,
                  child: Text(
                    entry.value,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: const Color(0xFF5A5A7A),
                    ),
                  ),
                ),
              );
            }
          }

          // Day cells
          for (int col = 0; col < numCols; col++) {
            for (int day = 0; day < 7; day++) {
              final key = '${row.rowIndex}-$col-$day';
              final cellInfo = activeMap[key];
              final isActive = cellInfo != null;

              // Compute the calendar date for this cell.
              final cellDate = row.rowStartDate.add(
                Duration(days: col * 7 + day),
              );
              final cellDateKey = DateTime(
                cellDate.year,
                cellDate.month,
                cellDate.day,
              );

              cells.add(
                Positioned(
                  left: col * stride,
                  top: rowTopY + _kLabelH + day * stride,
                  child:
                      isActive
                          ? GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap:
                                captureMode
                                    ? null
                                    : () {
                                      final dayMoments =
                                          momentsByDay[cellDateKey] ?? [];
                                      debugPrint(
                                        '[Activity tap] date=$cellDateKey  moments=${dayMoments.length}',
                                      );
                                      _showDayPopup(
                                        context,
                                        cellDateKey,
                                        dayMoments,
                                        friends,
                                      );
                                    },
                            child: _StarCell(
                              pulseAnim: pulseAnim,
                              staggerOffset: (cellInfo.starIndex * 0.13) % 1.0,
                              cellSize: cellSize,
                            ),
                          )
                          : captureMode
                          // Transparent placeholder — keeps layout intact
                          ? SizedBox(width: cellSize, height: cellSize)
                          : _EmptyCell(cellSize: cellSize),
                ),
              );
            }
          }
        }

        return SizedBox(
          width: availW,
          height: totalH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ...cells,
              // IgnorePointer so the dotted-lines overlay doesn't
              // swallow taps meant for the star cells underneath.
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _DottedLinesPainter(
                      activeCells: gridData.activeCells,
                      colH: colH,
                      stride: stride,
                      cellSize: cellSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Empty cell ───────────────────────────────────────────────────────────────

class _EmptyCell extends StatelessWidget {
  const _EmptyCell({required this.cellSize});

  final double cellSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        color: _kEmptyColor,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

// ─── Star cell ────────────────────────────────────────────────────────────────

class _StarCell extends StatelessWidget {
  const _StarCell({
    required this.pulseAnim,
    required this.staggerOffset,
    required this.cellSize,
  });

  final Animation<double> pulseAnim;
  final double staggerOffset;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Same background square as empty cells
          Container(
            width: cellSize,
            height: cellSize,
            decoration: BoxDecoration(
              color: _kEmptyColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Animated star on top
          Center(
            child: AnimatedBuilder(
              animation: pulseAnim,
              builder: (context, _) {
                final raw = (pulseAnim.value + staggerOffset) % 1.0;
                final t = math.sin(raw * math.pi);
                final scale = 1.0 + 0.4 * t;
                final glowOpacity = 0.3 + 0.7 * t;

                return Transform.scale(
                  scale: scale,
                  child: CustomPaint(
                    size: const Size(_kStarSize, _kStarSize),
                    painter: _StarPainter(glowOpacity: glowOpacity),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Star painter ─────────────────────────────────────────────────────────────

class _StarPainter extends CustomPainter {
  const _StarPainter({required this.glowOpacity});

  final double glowOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final outerR = cx;
    final innerR = outerR * 0.25;

    // Glow
    final glowPaint =
        Paint()
          ..color = _kGlowColor.withValues(alpha: glowOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
    canvas.drawCircle(Offset(cx, cy), outerR * 3.5, glowPaint);

    // 4-pointed star
    const numPoints = 4;
    final path = Path();
    for (int i = 0; i < numPoints * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = -math.pi / 2 + i * math.pi / numPoints;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = _kStarColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.glowOpacity != glowOpacity;
}

// ─── Dotted lines painter ─────────────────────────────────────────────────────

class _DottedLinesPainter extends CustomPainter {
  const _DottedLinesPainter({
    required this.activeCells,
    required this.colH,
    required this.stride,
    required this.cellSize,
  });

  final List<_CellInfo> activeCells;
  final double colH;
  final double stride;
  final double cellSize;

  static const _kDashLen = 3.0;
  static const _kGapLen = 3.0;

  Offset _center(_CellInfo c) {
    final rowTopY = c.rowIndex * (_kLabelH + colH + _kRowMargin);
    return Offset(
      c.colIndex * stride + cellSize / 2,
      rowTopY + _kLabelH + c.dayIndex * stride + cellSize / 2,
    );
  }

  void _dashedLine(Canvas canvas, Paint paint, Offset p1, Offset p2) {
    final d = (p2 - p1).distance;
    if (d < 1) return;
    final dir = (p2 - p1) / d;
    double drawn = 0;
    bool dash = true;
    while (drawn < d) {
      final segLen = dash ? _kDashLen : _kGapLen;
      if (dash) {
        canvas.drawLine(
          p1 + dir * drawn,
          p1 + dir * math.min(drawn + segLen, d),
          paint,
        );
      }
      drawn += segLen;
      dash = !dash;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (activeCells.length < 2) return;

    final paint =
        Paint()
          ..color = _kLineColor
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    for (int i = 0; i < activeCells.length - 1; i++) {
      final a = activeCells[i];
      final b = activeCells[i + 1];
      if (a.rowIndex != b.rowIndex) continue;
      _dashedLine(canvas, paint, _center(a), _center(b));
    }
  }

  @override
  bool shouldRepaint(_DottedLinesPainter old) =>
      old.activeCells.length != activeCells.length ||
      old.colH != colH ||
      old.stride != stride ||
      old.cellSize != cellSize;
}

// ─── Background picker sheet ──────────────────────────────────────────────────

class _BgPickerSheet extends StatefulWidget {
  const _BgPickerSheet({
    required this.activityByDay,
    required this.momentsByDay,
    required this.friends,
  });

  final Map<DateTime, int> activityByDay;
  final Map<DateTime, List<Moment>> momentsByDay;
  final List<Friend> friends;

  @override
  State<_BgPickerSheet> createState() => _BgPickerSheetState();
}

class _BgPickerSheetState extends State<_BgPickerSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  _ConstellationBg _selected = _ConstellationBg.darkBlue;
  late final _GridData _gridData;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _anim = _ctrl;
    _gridData = _buildH1Grid(widget.activityByDay);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF12121E),
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0x33FFFFFF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Choose background',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Option thumbnails
            SizedBox(
              height: 96,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final bg in _ConstellationBg.values)
                    _BgOptionTile(
                      bg: bg,
                      selected: _selected == bg,
                      onTap: () => setState(() => _selected = bg),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Live preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  decoration: _bgDecoration(_selected),
                  padding: const EdgeInsets.all(12),
                  child: _ConstellationGrid(
                    gridData: _gridData,
                    pulseAnim: _anim,
                    captureMode: true,
                    momentsByDay: widget.momentsByDay,
                    friends: widget.friends,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Confirm button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context, _selected),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8B8FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Save with this background',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0D0D1A),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _BgOptionTile extends StatelessWidget {
  const _BgOptionTile({
    required this.bg,
    required this.selected,
    required this.onTap,
  });

  final _ConstellationBg bg;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPhoto =
        bg == _ConstellationBg.photo1 || bg == _ConstellationBg.photo2;

    Widget content = Container(
      width: 64,
      height: 80,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? const Color(0xFFC8B8FF)
              : const Color(0x33FFFFFF),
          width: selected ? 2 : 1,
        ),
        color: !isPhoto
            ? (bg == _ConstellationBg.darkBlue
                ? _kDarkBg
                : const Color(0xFF222222))
            : null,
        image: isPhoto
            ? const DecorationImage(
                image: AssetImage('assets/images/home.png'),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (selected)
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFFC8B8FF), size: 16),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x99000000),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(11),
                bottomRight: Radius.circular(11),
              ),
            ),
            child: Text(
              _kBgLabel[bg]!,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 9,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(onTap: onTap, child: content);
  }
}

// ─── Day moments popup ────────────────────────────────────────────────────────

void _showDayPopup(
  BuildContext context,
  DateTime date,
  List<Moment> moments,
  List<Friend> friends,
) {
  showDialog<void>(
    context: context,
    builder:
        (_) => _DayMomentsPopup(date: date, moments: moments, friends: friends),
  );
}

class _DayMomentsPopup extends StatelessWidget {
  const _DayMomentsPopup({
    required this.date,
    required this.moments,
    required this.friends,
  });

  final DateTime date;
  final List<Moment> moments;
  final List<Friend> friends;

  static const _typeEmoji = {
    'coffee': '☕',
    'call': '📞',
    'text': '💬',
    'dinner': '🍽',
    'movie': '🎬',
    'shopping': '🛍',
    'other': '✨',
  };

  static const _typeLabel = {
    'coffee': 'Coffee',
    'call': 'Call',
    'text': 'Text',
    'dinner': 'Dinner',
    'movie': 'Movie',
    'shopping': 'Shopping',
    'other': 'Other',
  };

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String get _formattedDate =>
      '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';

  @override
  Widget build(BuildContext context) {
    final friendNames = {for (final f in friends) f.id: f.name};

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formattedDate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                      height: 1.2,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Color(0xFF96A8C2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: const Color(0xFFE2E8F0)),
            const SizedBox(height: 12),

            // ── Moments list ─────────────────────────────────────────────
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 380),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < moments.length; i++) ...[
                      _MomentRow(
                        moment: moments[i],
                        friendName:
                            friendNames[moments[i].friendId] ?? 'Unknown',
                        typeEmoji: _typeEmoji,
                        typeLabel: _typeLabel,
                      ),
                      if (i < moments.length - 1)
                        Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          color: const Color(0xFFE2E8F0),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MomentRow extends StatelessWidget {
  const _MomentRow({
    required this.moment,
    required this.friendName,
    required this.typeEmoji,
    required this.typeLabel,
  });

  final Moment moment;
  final String friendName;
  final Map<String, String> typeEmoji;
  final Map<String, String> typeLabel;

  @override
  Widget build(BuildContext context) {
    final emoji = typeEmoji[moment.type] ?? '✨';
    final label =
        moment.type == 'other' && moment.customType != null
            ? moment.customType!
            : (typeLabel[moment.type] ?? 'Other');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Emoji badge
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 12),

        // Text info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '· $friendName',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF96A8C2),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
              if (moment.note != null && moment.note!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  moment.note!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF334155),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
