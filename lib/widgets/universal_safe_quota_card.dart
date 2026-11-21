import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';
import 'impulse_quarantine_sheet.dart';

class UniversalSafeQuotaCard extends StatelessWidget {
  final StorageService storageService;
  final bool privacyMode;

  const UniversalSafeQuotaCard({
    super.key,
    required this.storageService,
    required this.privacyMode,
  });

  void _showCycleConfigSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CycleConfigModal(storageService: storageService),
    );
  }

  void _showQuarantineVault(BuildContext context) {
    ImpulseQuarantineSheet.show(context, storageService: storageService);
  }

  @override
  Widget build(BuildContext context) {
    final metrics = storageService.getDailySafeSpendingMetrics();
    final pendingCount = storageService.pendingImpulseItems.length;

    // Status logic
    final isOver = metrics.remainingQuota < 0;
    final isWarning = !isOver && metrics.percentUsed > 0.75;
    final isEssentialsOnly = metrics.isOverDueToEssentialsOnly;
    
    final Color statusColor = isEssentialsOnly
        ? AppTheme.electricCyan
        : (isOver
            ? AppTheme.neonCoral
            : (isWarning ? AppTheme.solarAmber : AppTheme.cyberMint));

    final String statusText = isEssentialsOnly
        ? 'KEBUTUHAN POKOK'
        : (isOver
            ? 'MELEBIHI KUOTA JAJAN'
            : (isWarning ? 'MENDEKATI LIMIT' : 'SANGAT AMAN'));

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isEssentialsOnly ? Icons.verified_outlined : Icons.shield_outlined,
                        size: 16,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KUOTA AMAN HARI INI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          isEssentialsOnly
                              ? 'Kebutuhan pokok & operasional terdeteksi'
                              : 'Batas aman jajan agar tidak tekor',
                          style: TextStyle(
                            fontSize: 10,
                            color: isEssentialsOnly
                                ? AppTheme.electricCyan.withValues(alpha: 0.8)
                                : Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Main Metric Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        privacyMode
                            ? 'Rp ••••••••'
                            : CurrencyFormatter.formatRp(metrics.remainingQuota.clamp(0, double.infinity)),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: isEssentialsOnly
                              ? AppTheme.electricCyan
                              : (isOver ? AppTheme.neonCoral : Colors.white),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        privacyMode
                            ? 'Sisa dari jatah harian: Rp •••'
                            : (isEssentialsOnly
                                ? 'Alokasi pokok ${CurrencyFormatter.formatRp(metrics.essentialSpent)} • Jajan aman (${CurrencyFormatter.formatRp(metrics.discretionarySpent)})'
                                : (isOver
                                    ? 'Tekor jajan ${CurrencyFormatter.formatRp(metrics.remainingQuota.abs())} hari ini'
                                    : 'Tersisa dari total kuota ${CurrencyFormatter.formatRp(metrics.safeQuota)}/hari')),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isEssentialsOnly
                              ? AppTheme.electricCyan.withValues(alpha: 0.9)
                              : (isOver ? AppTheme.neonCoral.withValues(alpha: 0.9) : Colors.white54),
                        ),
                      ),
                    ],
                  ),
                ),
                // Quota Cycle Badge Action
                InkWell(
                  onTap: () => _showCycleConfigSheet(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tune_rounded, size: 13, color: AppTheme.cyberMint),
                        const SizedBox(width: 5),
                        Text(
                          '${metrics.daysLeftInCycle} Hari Lagi ›',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.cyberMint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  FractionallySizedBox(
                    widthFactor: metrics.percentUsed.clamp(0.0, 1.0),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor.withValues(alpha: 0.7),
                            statusColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (metrics.spentToday > 0) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.electricCyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.electricCyan.withValues(alpha: 0.3), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 10, color: AppTheme.electricCyan),
                        const SizedBox(width: 4),
                        Text(
                          'Pokok: ${privacyMode ? 'Rp •••' : CurrencyFormatter.formatRp(metrics.essentialSpent)}',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppTheme.electricCyan),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (metrics.discretionarySpent > metrics.safeQuota)
                          ? AppTheme.neonCoral.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: (metrics.discretionarySpent > metrics.safeQuota)
                            ? AppTheme.neonCoral.withValues(alpha: 0.3)
                            : Colors.white12,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_cafe_rounded,
                          size: 10,
                          color: (metrics.discretionarySpent > metrics.safeQuota) ? AppTheme.neonCoral : Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Jajan: ${privacyMode ? 'Rp •••' : CurrencyFormatter.formatRp(metrics.discretionarySpent)}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: (metrics.discretionarySpent > metrics.safeQuota) ? AppTheme.neonCoral : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Bottom Action Bar: Cycle status & Impulse Quarantine button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(21)),
              border: const Border(
                top: BorderSide(color: Colors.white10, width: 0.8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cycle Type info
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.repeat_rounded, size: 14, color: Colors.white54),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          metrics.cycleLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Impulse Vault Trigger
                InkWell(
                  onTap: () => _showQuarantineVault(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: pendingCount > 0
                          ? AppTheme.electricIndigo.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: pendingCount > 0
                            ? AppTheme.electricIndigo.withValues(alpha: 0.5)
                            : Colors.white24,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.hourglass_top_rounded,
                          size: 13,
                          color: pendingCount > 0 ? const Color(0xFF818CF8) : Colors.white60,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          pendingCount > 0
                              ? '$pendingCount Tertahan'
                              : 'Kotak Pending',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: pendingCount > 0 ? const Color(0xFF818CF8) : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleConfigModal extends StatefulWidget {
  final StorageService storageService;

  const _CycleConfigModal({required this.storageService});

  @override
  State<_CycleConfigModal> createState() => _CycleConfigModalState();
}

class _CycleConfigModalState extends State<_CycleConfigModal> {
  late String _cycleType;
  late int _refillDay;

  @override
  void initState() {
    super.initState();
    _cycleType = widget.storageService.cycleType;
    _refillDay = widget.storageService.refillDay;
  }

  void _save() async {
    await widget.storageService.setCycleConfiguration(
      cycleType: _cycleType,
      refillDay: _refillDay,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceCardElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Icon(Icons.tune_rounded, color: AppTheme.cyberMint, size: 20),
              SizedBox(width: 10),
              Text(
                'Siklus Isi Dompet (Refill)',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Sesuaikan ritme dana Anda agar kuota belanja harian dihitung secara akurat tanpa membuat Anda stres.',
            style: TextStyle(fontSize: 12, color: Colors.white54, height: 1.4),
          ),
          const SizedBox(height: 18),

          // Option 1: Bulanan (Anak Kos / Mahasiswa / Pekerja)
          _buildCycleOption(
            type: 'monthly',
            title: 'Bulanan (Kiriman / Gaji)',
            subtitle: 'Cocok untuk mahasiswa anak kos (kiriman tgl 1) atau pekerja',
            icon: Icons.calendar_month_rounded,
          ),
          if (_cycleType == 'monthly') ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Row(
                children: [
                  const Text('Tanggal Refill: ', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _refillDay.clamp(1, 31),
                    dropdownColor: AppTheme.surfaceCard,
                    style: const TextStyle(color: AppTheme.cyberMint, fontWeight: FontWeight.bold, fontSize: 14),
                    items: List.generate(31, (i) => i + 1).map((d) {
                      return DropdownMenuItem(value: d, child: Text('Tanggal $d'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _refillDay = val);
                    },
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Option 2: Mingguan (Anak SMA / Uang Saku Senin)
          _buildCycleOption(
            type: 'weekly',
            title: 'Mingguan (Uang Saku)',
            subtitle: 'Cocok untuk pelajar / anak sekolah yang dapat jatah per minggu',
            icon: Icons.view_week_rounded,
          ),
          if (_cycleType == 'weekly') ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Row(
                children: [
                  const Text('Hari Diberikan: ', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _refillDay.clamp(1, 7),
                    dropdownColor: AppTheme.surfaceCard,
                    style: const TextStyle(color: AppTheme.cyberMint, fontWeight: FontWeight.bold, fontSize: 14),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Senin')),
                      DropdownMenuItem(value: 2, child: Text('Selasa')),
                      DropdownMenuItem(value: 3, child: Text('Rabu')),
                      DropdownMenuItem(value: 4, child: Text('Kamis')),
                      DropdownMenuItem(value: 5, child: Text('Jumat')),
                      DropdownMenuItem(value: 6, child: Text('Sabtu')),
                      DropdownMenuItem(value: 7, child: Text('Minggu')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _refillDay = val);
                    },
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Option 3: Bebas (Freelance / Kas Tetap)
          _buildCycleOption(
            type: 'free',
            title: 'Mode Bebas (Tanpa Siklus Tetap)',
            subtitle: 'Cocok untuk freelancer atau mengukur daya tahan total saldo sampai habis',
            icon: Icons.all_inclusive_rounded,
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cyberMint,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _save,
              child: const Text(
                'Terapkan Siklus',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleOption({
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _cycleType == type;
    return InkWell(
      onTap: () => setState(() => _cycleType = type),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.cyberMint.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.cyberMint : Colors.white12,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppTheme.cyberMint : Colors.white60,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? AppTheme.cyberMint : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              size: 18,
              color: isSelected ? AppTheme.cyberMint : Colors.white24,
            ),
          ],
        ),
      ),
    );
  }
}
