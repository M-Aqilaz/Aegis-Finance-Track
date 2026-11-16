import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pocket_transfer.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/asset_dialogs.dart';
import '../widgets/titanium_card.dart';
import '../widgets/transfer_dialog.dart';

class AssetScreen extends StatefulWidget {
  final StorageService storageService;

  const AssetScreen({super.key, required this.storageService});

  @override
  State<AssetScreen> createState() => _AssetScreenState();
}

class _AssetScreenState extends State<AssetScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.storageService,
      builder: (context, _) {
        final s = widget.storageService;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final cash = s.cashBalance;
        final savings = s.savingsBalance;
        final totalAssets = s.totalAllAssets;

        // Dynamic asset slices for distribution chart
        final List<_AssetSlice> slices = [];
        if (cash > 0) {
          slices.add(_AssetSlice('Cash', cash, const Color(0xFF10B981), Icons.payments_outlined));
        }
        if (savings > 0) {
          slices.add(_AssetSlice('Tabungan', savings, const Color(0xFF06B6D4), Icons.savings_outlined));
        }
        for (var asset in s.customAssets) {
          if (asset.balance > 0) {
            slices.add(_AssetSlice(asset.name, asset.balance, asset.color, asset.icon));
          }
        }
        final totalInPockets = slices.fold(0.0, (sum, item) => sum + item.amount);

        return Scaffold(
          backgroundColor: AppTheme.obsidianBg,
          appBar: AppBar(
            backgroundColor: AppTheme.obsidianBg,
            elevation: 0,
            title: const Text('Kantong Aset & Analisis', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.swap_horiz_rounded),
                tooltip: 'Pindah Saldo',
                onPressed: () => TransferDialog.show(
                  context,
                  storageService: s,
                  initialFromPocketId: StorageService.kPocketSavingsId,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Tambah Aset',
                onPressed: () {
                  AssetDialogs.showAddEditAsset(context, storageService: s);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Signature Black Titanium VIP Card
                TitaniumCard(
                  totalAllAssets: totalAssets,
                  cashBalance: cash,
                  savingsBalance: savings,
                  otherAssetsBalance: s.customAssets.fold(0.0, (sum, a) => sum + a.balance),
                  onTransfer: () => TransferDialog.show(
                    context,
                    storageService: s,
                    initialFromPocketId: StorageService.kPocketSavingsId,
                  ),
                ),

                const SizedBox(height: 20),

                // Asset Distribution Donut Chart
                if (slices.isNotEmpty && totalInPockets > 0) ...[
                  const Text('Distribusi Penyimpanan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.glassCardDecoration(borderRadius: 20),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 180,
                          child: PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection == null) {
                                      _touchedIndex = -1;
                                      return;
                                    }
                                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                  });
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 3,
                              centerSpaceRadius: 40,
                              sections: List.generate(slices.length, (i) {
                                final isTouched = i == _touchedIndex;
                                final item = slices[i];
                                final pct = totalInPockets > 0 ? (item.amount / totalInPockets) * 100 : 0.0;
                                final radius = isTouched ? 55.0 : 45.0;
                                return PieChartSectionData(
                                  color: item.color,
                                  value: item.amount,
                                  title: '${pct.toStringAsFixed(0)}%',
                                  radius: radius,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...slices.map((slice) {
                          final pct = totalInPockets > 0 ? (slice.amount / totalInPockets) * 100 : 0.0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${slice.name} (${pct.toStringAsFixed(1)}%)',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.formatRp(slice.amount),
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: slice.color),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Dynamic Pockets Management Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kantong Saldo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: const Color(0xFF6366F1),
                      ),
                      onPressed: () {
                        AssetDialogs.showAddEditAsset(context, storageService: s);
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Tambah Aset', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 1. Cash Card (Permanent)
                _buildPocketTile(
                  title: 'Cash (Tunai)',
                  amount: cash,
                  color: const Color(0xFF10B981),
                  icon: Icons.payments_outlined,
                  isDark: isDark,
                  onTransfer: () {
                    TransferDialog.show(
                      context,
                      storageService: s,
                      initialFromPocketId: StorageService.kPocketCashId,
                    );
                  },
                ),

                // 2. Tabungan Card (Permanent from Total Simpan)
                _buildPocketTile(
                  title: 'Tabungan (Simpanan)',
                  amount: savings,
                  color: const Color(0xFF06B6D4),
                  icon: Icons.savings_outlined,
                  isDark: isDark,
                  onTransfer: () {
                    TransferDialog.show(
                      context,
                      storageService: s,
                      initialFromPocketId: StorageService.kPocketSavingsId,
                    );
                  },
                ),

                // 3. Dynamic Custom Assets Cards
                ...s.customAssets.map((asset) {
                  return _buildPocketTile(
                    title: asset.name,
                    amount: asset.balance,
                    color: asset.color,
                    icon: asset.icon,
                    isDark: isDark,
                    onTransfer: () {
                      TransferDialog.show(
                        context,
                        storageService: s,
                        initialFromPocketId: asset.id,
                      );
                    },
                    onEdit: () {
                      AssetDialogs.showQuickEditBalance(
                        context,
                        assetName: asset.name,
                        currentBalance: asset.balance,
                        onSave: (val) => s.updateAssetBalance(asset.id, val),
                      );
                    },
                    onDetailEdit: () {
                      AssetDialogs.showAddEditAsset(
                        context,
                        storageService: s,
                        existingAsset: asset,
                      );
                    },
                  );
                }),

                const SizedBox(height: 20),

                // Riwayat Pemindahan Saldo (Transfers History)
                if (s.transfers.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Riwayat Pindah Dana', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(
                        '${s.transfers.length} transaksi',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...s.transfers.map((t) => _buildTransferItem(context, t, isDark, s)),
                  const SizedBox(height: 20),
                ],

                // Kurva Pertumbuhan Tabungan (Savings Growth Curve)
                _buildSavingsGrowthChart(s, isDark),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavingsGrowthChart(StorageService s, bool isDark) {
    final entries = s.entries;
    final hasData = entries.isNotEmpty && s.savingsBalance > 0;

    // Build data points
    List<FlSpot> spots = [];
    double maxVal = s.savingsBalance;

    if (entries.isEmpty) {
      spots = [const FlSpot(0, 0)];
    } else {
      for (int i = 0; i < entries.length; i++) {
        final val = entries[i].runningTotalSimpan;
        if (val > maxVal) maxVal = val;
        spots.add(FlSpot(i.toDouble(), val));
      }
      if (spots.length == 1) {
        spots.insert(0, const FlSpot(-1, 0));
      }
    }

    final maxY = maxVal > 0 ? maxVal * 1.25 : 100000.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.trending_up_rounded, color: Color(0xFF06B6D4), size: 18),
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kurva Pertumbuhan Tabungan',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Akumulasi simpanan seiring waktu',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.3)),
              ),
              child: Text(
                CurrencyFormatter.formatShort(s.savingsBalance),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF06B6D4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 230,
          padding: const EdgeInsets.fromLTRB(8, 16, 12, 12),
          decoration: AppTheme.glassCardDecoration(borderRadius: 20),
          child: !hasData
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.savings_outlined, size: 36, color: Colors.grey.withValues(alpha: 0.5)),
                      const SizedBox(height: 8),
                      const Text(
                        'Belum Ada Akumulasi Tabungan',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Catat porsi simpanan atau pindahkan dana ke tabungan',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 25000,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.white.withValues(alpha: 0.05),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: spots.length > 6
                              ? (spots.length / 4).ceilToDouble()
                              : spots.length > 3
                                  ? 2
                                  : 1,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            // Skip first and last to prevent edge clipping
                            if (idx < 0 ||
                                idx >= entries.length ||
                                value == meta.min ||
                                value == meta.max) {
                              return const SizedBox.shrink();
                            }
                            return SideTitleWidget(
                              meta: meta,
                              fitInside: SideTitleFitInsideData.fromTitleMeta(
                                meta,
                                enabled: true,
                                distanceFromEdge: 2,
                              ),
                              child: Text(
                                DateFormat('d MMM').format(entries[idx].date),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 46,
                          interval: maxY / 4 > 0 ? maxY / 4 : 25000,
                          getTitlesWidget: (value, meta) {
                            if (value <= 0 || value >= maxY * 0.98) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              CurrencyFormatter.formatShort(value),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minY: 0,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: spots.length <= 10,
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: 3,
                            color: const Color(0xFF06B6D4),
                            strokeWidth: 1.5,
                            strokeColor: Colors.white,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF06B6D4).withValues(alpha: 0.28),
                              const Color(0xFF06B6D4).withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => const Color(0xFF1E293B),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final idx = spot.x.toInt().clamp(0, entries.length - 1);
                            final entryDate = entries.isNotEmpty ? entries[idx].date : DateTime.now();
                            return LineTooltipItem(
                              '${DateFormat('dd MMM yyyy').format(entryDate)}\n',
                              const TextStyle(color: Colors.white70, fontSize: 10),
                              children: [
                                TextSpan(
                                  text: CurrencyFormatter.formatRp(spot.y),
                                  style: const TextStyle(
                                    color: Color(0xFF06B6D4),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }


  Widget _buildPocketTile({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    required bool isDark,
    VoidCallback? onTransfer,
    VoidCallback? onEdit,
    VoidCallback? onDetailEdit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppTheme.glassCardDecoration(borderRadius: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
                      Text(
                        CurrencyFormatter.formatRp(amount),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onTransfer != null)
                IconButton(
                  icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                  color: const Color(0xFF6366F1),
                  onPressed: onTransfer,
                  tooltip: 'Pindahkan Dana',
                ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEdit,
                  tooltip: 'Ubah Saldo Manual',
                ),
              if (onDetailEdit != null)
                IconButton(
                  icon: const Icon(Icons.more_horiz, size: 18),
                  onPressed: onDetailEdit,
                  tooltip: 'Opsi Aset',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransferItem(BuildContext context, PocketTransfer t, bool isDark, StorageService s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.glassCardDecoration(borderRadius: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF6366F1), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      t.fromPocketName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.arrow_forward_rounded, size: 12, color: Colors.grey),
                    ),
                    Text(
                      t.toPocketName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ],
                ),
                if (t.note.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    t.note,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.formatDate(t.date),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.formatRp(t.amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF6366F1),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
            tooltip: 'Batalkan Pindah Dana',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Batalkan Pemindahan?'),
                  content: Text('Saldo ${CurrencyFormatter.formatRp(t.amount)} akan dikembalikan ke ${t.fromPocketName}.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Kembalikan'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await s.deleteTransfer(t.id);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _AssetSlice {
  final String name;
  final double amount;
  final Color color;
  final IconData icon;

  _AssetSlice(this.name, this.amount, this.color, this.icon);
}
