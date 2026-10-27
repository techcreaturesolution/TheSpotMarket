import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config/app_config.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/allotment_service.dart';
import '../widgets/common.dart';

class AllotmentScreen extends StatelessWidget {
  const AllotmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Only select allotment-related data — not market indices that tick every second.
    final ipos = context.select<AppState, List<Ipo>>((s) => s.ipos);
    final profiles = context.select<AppState, List<PanProfile>>((s) => s.profiles);
    final checkable = ipos
        .where((i) => i.status == IpoStatus.closed || i.status == IpoStatus.listed)
        .toList();
    final s = context.read<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('IPO Allotment')),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'add-pan',
        onPressed: () => showPanDialog(context),
        child: const Icon(Icons.person_add_alt_1, size: 18),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          SectionHeader(
            'Family & friends (${profiles.length} PAN${profiles.length == 1 ? '' : 's'})',
            action: 'Add PAN',
            onAction: () => showPanDialog(context),
          ),
          if (profiles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      const Color(0xFF0C2016).withValues(alpha: 0.40),
                      const Color(0xFF030D08).withValues(alpha: 0.70),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.4), width: 1),
                      ),
                      child: const Icon(Icons.badge_outlined, color: Color(0xFF34D399), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add PAN cards for 1-tap allotment check',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Check allotment for family & friends at once. Stored locally.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => showPanDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF10B981)]),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF042013))),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...s.profiles.map((p) => _ProfileTile(profile: p)),
          const SectionHeader('Check allotment status'),
          if (checkable.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'No IPO has closed recently. Allotment can be checked after the issue closes.',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
              ),
            )
          else
            ...checkable.map((ipo) {
              final results = s.allotmentsForIpo(ipo.id);
              final allotted = results.where((r) => r.outcome == AllotmentOutcome.allotted).length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      const Color(0xFF0C2016).withValues(alpha: 0.35),
                      const Color(0xFF030D08).withValues(alpha: 0.65),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.11),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  title: Text(
                    ipo.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Allotment ${ipo.allotmentDate != null ? dateFmt.format(ipo.allotmentDate!) : "—"} · Listing ${ipo.listingDate != null ? dateFmt.format(ipo.listingDate!) : "—"} · ${ipo.registrar}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.60),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (results.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: allotted > 0
                                  ? const Color(0xFF10B981).withValues(alpha: .15)
                                  : Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: allotted > 0
                                    ? const Color(0xFF10B981).withValues(alpha: 0.3)
                                    : Colors.white12,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              '$allotted/${results.length} Allotted',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: allotted > 0
                                    ? const Color(0xFF34D399)
                                    : Colors.white70,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, size: 18, color: Colors.white.withValues(alpha: 0.45)),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AllotmentCheckScreen(ipo: ipo)),
                  ),
                ),
              );
            }),
          const SectionHeader('Registrar portals'),
          ...AppConfig.registrars.map((r) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withValues(alpha: 0.04),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 0.9,
                  ),
                ),
                child: ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.language, size: 16, color: Color(0xFF34D399)),
                  ),
                  title: Text(
                    r.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  trailing: Icon(Icons.open_in_new, size: 14, color: Colors.white.withValues(alpha: 0.45)),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegistrarWebView(registrar: r, profiles: s.profiles),
                    ),
                  ),
                ),
              )),
        ],  
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.profile});
  final PanProfile profile;

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final masked = '${profile.pan.substring(0, 5)}••••${profile.pan.substring(9)}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            const Color(0xFF0C2016).withValues(alpha: 0.35),
            const Color(0xFF030D08).withValues(alpha: 0.65),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.11),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF10B981).withValues(alpha: 0.18),
            border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.4), width: 1),
          ),
          child: Center(
            child: Text(
              profile.name.isEmpty ? '?' : profile.name[0].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF34D399), fontSize: 13),
            ),
          ),
        ),
        title: Text(
          profile.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
            color: Colors.white,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                masked,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
            ),
            if (profile.dpId != null) ...[
              const SizedBox(width: 6),
              Text(
                'DP: ${profile.dpId}',
                style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : const Color(0xFF94A3B8)),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF94A3B8)),
          onSelected: (v) async {
            if (v == 'copy') {
              await Clipboard.setData(ClipboardData(text: profile.pan));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PAN copied')));
              }
            } else if (v == 'edit') {
              if (context.mounted) showPanDialog(context, existing: profile);
            } else if (v == 'delete') {
              s.removeProfile(profile.id);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'copy', child: Text('Copy PAN')),
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Remove')),
          ],
        ),
      ),
    );
  }
}

Future<void> showPanDialog(BuildContext context, {PanProfile? existing}) {
  final name = TextEditingController(text: existing?.name);
  final pan = TextEditingController(text: existing?.pan);
  final app = TextEditingController(text: existing?.applicationNumber);
  final dp = TextEditingController(text: existing?.dpId);
  String? error;

  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.80),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F261B),
                Color(0xFF08150E),
                Color(0xFF030A07),
              ],
              stops: [0.0, 0.45, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.70),
                blurRadius: 36,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.20),
                blurRadius: 28,
                spreadRadius: -4,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF10B981).withValues(alpha: 0.18),
                          border: Border.all(
                            color: const Color(0xFF34D399).withValues(alpha: 0.45),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.badge_outlined,
                          color: Color(0xFF34D399),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              existing == null ? 'Add PAN' : 'Edit PAN',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Stored locally for 1-tap allotment check',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                          ),
                          child: const Icon(Icons.close_rounded, size: 16, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (error != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.40),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              error!,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  _buildGlassPanField(
                    controller: name,
                    label: 'Name',
                    hint: 'e.g. Ramesh Patel',
                    icon: Icons.person_outline_rounded,
                    capitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  _buildGlassPanField(
                    controller: pan,
                    label: 'PAN number',
                    hint: 'ABCDE1234F',
                    icon: Icons.credit_card_outlined,
                    capitalization: TextCapitalization.characters,
                    maxLength: 10,
                    formatters: [FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]'))],
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  _buildGlassPanField(
                    controller: app,
                    label: 'Application no. (optional)',
                    hint: 'e.g. 12345678',
                    icon: Icons.tag_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildGlassPanField(
                    controller: dp,
                    label: 'DP ID / Client ID (optional)',
                    hint: 'e.g. IN300123 / 12345678',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: Colors.white.withValues(alpha: 0.06),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final s = ctx.read<AppState>();
                            if (name.text.trim().isEmpty) {
                              setState(() => error = 'Enter a name');
                              return;
                            }
                            String? err;
                            if (existing == null) {
                              err = await s.addProfile(name.text, pan.text, applicationNumber: app.text, dpId: dp.text);
                            } else {
                              final upper = pan.text.toUpperCase();
                              if (!PanProfile.isValidPan(upper)) {
                                err = 'Invalid PAN format';
                              } else {
                                await s.updateProfile(existing.copyWith(
                                  name: name.text,
                                  pan: upper,
                                  applicationNumber: app.text.trim().isEmpty ? null : app.text.trim(),
                                  dpId: dp.text.trim().isEmpty ? null : dp.text.trim(),
                                ));
                              }
                            }
                            if (err != null) {
                              setState(() => error = err);
                            } else if (ctx.mounted) {
                              Navigator.pop(ctx);
                            }
                          },
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF34D399), Color(0xFF10B981), Color(0xFF059669)],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                                width: 1.1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.40),
                                  blurRadius: 14,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Save',
                                style: TextStyle(
                                  color: Color(0xFF032213),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildGlassPanField({
  required TextEditingController controller,
  required String label,
  String? hint,
  required IconData icon,
  TextCapitalization capitalization = TextCapitalization.none,
  int? maxLength,
  List<TextInputFormatter>? formatters,
  ValueChanged<String>? onChanged,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      color: Colors.white.withValues(alpha: 0.05),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.10),
        width: 1,
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
    child: TextField(
      controller: controller,
      textCapitalization: capitalization,
      maxLength: maxLength,
      inputFormatters: formatters,
      onChanged: onChanged,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 13.5,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        counterText: '',
        icon: Icon(icon, size: 18, color: const Color(0xFF34D399)),
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.55),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.25),
          fontSize: 12,
        ),
        suffix: maxLength != null
            ? Text(
                '${controller.text.length}/$maxLength',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: controller.text.length == maxLength
                      ? const Color(0xFF34D399)
                      : Colors.white.withValues(alpha: 0.40),
                ),
              )
            : null,
      ),
    ),
  );
}

class AllotmentCheckScreen extends StatelessWidget {
  const AllotmentCheckScreen({super.key, required this.ipo});
  final Ipo ipo;

  @override
  Widget build(BuildContext context) {
    // Select only allotment-related data — avoids rebuilding on market ticks.
    final profiles = context.select<AppState, List<PanProfile>>((s) => s.profiles);
    final allotmentResults = context.select<AppState, List<AllotmentResult>>(
      (s) => s.allotmentsForIpo(ipo.id),
    );
    final s = context.read<AppState>();
    final registrar = AllotmentService.registrarFor(ipo);
    final results = {for (final r in allotmentResults) r.profileId: r};
    final allotted = results.values.where((r) => r.outcome == AllotmentOutcome.allotted).length;
    final notAllotted = results.values.where((r) => r.outcome == AllotmentOutcome.notAllotted).length;
    final pendingCount = (profiles.length - allotted - notAllotted).clamp(0, 999);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${ipo.name} allotment',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      bottomNavigationBar: const BannerAdWidget(),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Liquid Glass summary box
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  const Color(0xFF0C2016).withValues(alpha: 0.40),
                  const Color(0xFF030D08).withValues(alpha: 0.70),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.13),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _Count('Allotted', allotted, const Color(0xFF10B981)),
                Container(height: 32, width: 1, color: Colors.white.withValues(alpha: 0.12)),
                _Count('Not allotted', notAllotted, const Color(0xFFEF4444)),
                Container(height: 32, width: 1, color: Colors.white.withValues(alpha: 0.12)),
                _Count('Pending', pendingCount, const Color(0xFFF59E0B)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.business_center_outlined, size: 14, color: Color(0xFF34D399)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Registrar: ${ipo.registrar}  •  Allotment Date: ${ipo.allotmentDate != null ? dateFullFmt.format(ipo.allotmentDate!) : 'TBA'}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.70),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (s.profiles.isEmpty)
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    const Color(0xFF0C2016).withValues(alpha: 0.40),
                    const Color(0xFF030D08).withValues(alpha: 0.70),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.40)),
                    ),
                    child: const Icon(Icons.person_add_alt_1, size: 30, color: Color(0xFF34D399)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No PAN added yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add PAN cards of family & friends to check everyone in one go.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => showPanDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF34D399), Color(0xFF10B981)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 18, color: Color(0xFF042013)),
                          SizedBox(width: 6),
                          Text('Add PAN', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF042013))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            GestureDetector(
              onTap: s.checkingAllotment
                  ? null
                  : () async {
                      if (s.allotmentService.supportsAutoCheck) {
                        final err = await s.checkAllotmentsFor(ipo);
                        if (err != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                        }
                      } else if (registrar != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegistrarWebView(
                              registrar: registrar,
                              profiles: s.profiles,
                              ipo: ipo,
                            ),
                          ),
                        );
                      }
                    },
              child: Container(
                width: double.infinity,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(23),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF34D399), Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.40),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: s.checkingAllotment
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF032213)),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search, size: 18, color: Color(0xFF032213)),
                            const SizedBox(width: 8),
                            Text(
                              s.allotmentService.supportsAutoCheck
                                  ? 'Check all ${s.profiles.length} PANs'
                                  : 'Open registrar & check',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                color: Color(0xFF032213),
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            if (!s.allotmentService.supportsAutoCheck)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  'Registrar sites require CAPTCHA verification. The app auto-fills each PAN so you can easily solve CAPTCHA and submit.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ...s.profiles.map((p) {
              final r = results[p.id];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      const Color(0xFF0C2016).withValues(alpha: 0.35),
                      const Color(0xFF030D08).withValues(alpha: 0.65),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: _OutcomeIcon(r?.outcome ?? AllotmentOutcome.unknown),
                  title: Text(
                    p.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF10B981).withValues(alpha: 0.30),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            p.pan,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: Color(0xFF34D399),
                            ),
                          ),
                        ),
                        if (r?.sharesAllotted != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF34D399).withValues(alpha: 0.45),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              '${r!.sharesAllotted} shares',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF34D399),
                              ),
                            ),
                          ),
                        if (r != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Checked ${timeAgo(r.checkedAt)}',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.white.withValues(alpha: 0.50),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<AllotmentOutcome>(
                    tooltip: 'Record result',
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                      child: const Icon(Icons.edit_note_rounded, size: 18, color: Colors.white70),
                    ),
                    onSelected: (o) => _record(context, p, o),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: AllotmentOutcome.allotted, child: Text('Allotted')),
                      PopupMenuItem(value: AllotmentOutcome.notAllotted, child: Text('Not allotted')),
                      PopupMenuItem(value: AllotmentOutcome.pending, child: Text('Pending')),
                    ],
                  ),
                  onTap: registrar == null
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RegistrarWebView(
                                registrar: registrar,
                                profiles: [p],
                                ipo: ipo,
                              ),
                            ),
                          ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Future<void> _record(BuildContext context, PanProfile p, AllotmentOutcome o) async {
    int? shares;
    if (o == AllotmentOutcome.allotted) {
      final defaultLot = ipo.lotSize ?? 50;
      final c = TextEditingController(text: defaultLot.toString());
      shares = await showDialog<int>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF07140E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          ),
          title: Text('Shares allotted to ${p.name}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          content: TextField(
            controller: c,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Number of shares',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white60))),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              onPressed: () => Navigator.pop(ctx, int.tryParse(c.text) ?? defaultLot),
              child: const Text('Save', style: TextStyle(color: Color(0xFF042013), fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      );
      if (shares == null) return;
    }
    if (!context.mounted) return;
    await context.read<AppState>().recordAllotment(AllotmentResult(
          profileId: p.id,
          ipoId: ipo.id,
          outcome: o,
          checkedAt: DateTime.now(),
          sharesAllotted: shares,
        ));
  }
}

class _Count extends StatelessWidget {
  const _Count(this.label, this.count, this.color);
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutcomeIcon extends StatelessWidget {
  const _OutcomeIcon(this.outcome);
  final AllotmentOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final (icon, color, bg, border) = switch (outcome) {
      AllotmentOutcome.allotted => (
          Icons.check_circle_rounded,
          const Color(0xFF10B981),
          const Color(0xFF10B981).withValues(alpha: 0.18),
          const Color(0xFF34D399).withValues(alpha: 0.40),
        ),
      AllotmentOutcome.notAllotted => (
          Icons.cancel_rounded,
          const Color(0xFFEF4444),
          const Color(0xFFEF4444).withValues(alpha: 0.18),
          const Color(0xFFEF4444).withValues(alpha: 0.40),
        ),
      AllotmentOutcome.pending => (
          Icons.hourglass_top_rounded,
          const Color(0xFFF59E0B),
          const Color(0xFFF59E0B).withValues(alpha: 0.18),
          const Color(0xFFF59E0B).withValues(alpha: 0.40),
        ),
      AllotmentOutcome.unknown => (
          Icons.help_outline_rounded,
          const Color(0xFF94A3B8),
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.14),
        ),
    };

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 1),
      ),
      child: Center(
        child: Icon(icon, color: color, size: 19),
      ),
    );
  }
}

/// In-app registrar page. Cycles through the given PANs, auto-filling each
/// one; the user solves the CAPTCHA and records the outcome.
class RegistrarWebView extends StatefulWidget {
  const RegistrarWebView({super.key, required this.registrar, required this.profiles, this.ipo});
  final Registrar registrar;
  final List<PanProfile> profiles;
  final Ipo? ipo;

  @override
  State<RegistrarWebView> createState() => _RegistrarWebViewState();
}

class _RegistrarWebViewState extends State<RegistrarWebView> {
  late final WebViewController _controller;
  int _current = 0;
  bool _loading = true;
  bool _isTrusted = false;

  PanProfile? get _profile => widget.profiles.isEmpty ? null : widget.profiles[_current];

  @override
  void initState() {
    super.initState();
    _isTrusted = AllotmentService.isTrustedRegistrarUrl(widget.registrar.url);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          if (AllotmentService.isTrustedRegistrarUrl(request.url)) {
            return NavigationDecision.navigate;
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Navigation to unverified external domain blocked for security.')),
            );
          }
          return NavigationDecision.prevent;
        },
        onPageStarted: (_) {
          if (mounted) setState(() => _loading = true);
        },
        onPageFinished: (_) {
          if (mounted) {
            setState(() => _loading = false);
            _fill();
          }
        },
        onWebResourceError: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ));

    if (_isTrusted) {
      _controller.loadRequest(Uri.parse(widget.registrar.url));
    } else {
      _loading = false;
    }
  }

  Future<void> _fill() async {
    final p = _profile;
    if (p == null || !_isTrusted) return;
    try {
      final currentUrl = await _controller.currentUrl();
      if (!AllotmentService.isTrustedRegistrarUrl(currentUrl)) {
        return;
      }
      await _controller.runJavaScript(AllotmentService.prefillScript(p.pan));
    } catch (_) {}
  }

  Future<void> _copyPan() async {
    final p = _profile;
    if (p == null) return;
    await Clipboard.setData(ClipboardData(text: p.pan));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.pan} copied – paste it in the PAN field')));
    }
  }

  Future<void> _record(AllotmentOutcome o) async {
    final p = _profile;
    final ipo = widget.ipo;
    if (p == null || ipo == null) return;
    await context.read<AppState>().recordAllotment(AllotmentResult(
          profileId: p.id,
          ipoId: ipo.id,
          outcome: o,
          checkedAt: DateTime.now(),
          sharesAllotted: o == AllotmentOutcome.allotted ? (ipo.lotSize ?? 50) : null,
        ));
    if (_current < widget.profiles.length - 1) {
      if (mounted) {
        setState(() => _current++);
        _controller.reload();
      }
    } else if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _openExternal() async {
    try {
      final uri = Uri.parse(widget.registrar.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final p = _profile;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.registrar.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Open in browser',
            onPressed: _openExternal,
          ),
          if (_isTrusted)
            IconButton(icon: const Icon(Icons.refresh), onPressed: _controller.reload),
        ],
        bottom: _loading ? const PreferredSize(preferredSize: Size.fromHeight(3), child: LinearProgressIndicator()) : null,
      ),
      body: Column(children: [
        if (p != null)
          Container(
            color: const Color(0xFF07140E),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    '${_current + 1}/${widget.profiles.length} · ${p.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    p.pan,
                    style: const TextStyle(fontSize: 12, letterSpacing: 1, color: Color(0xFF34D399), fontWeight: FontWeight.w700),
                  ),
                ]),
              ),
              IconButton(tooltip: 'Copy PAN', icon: const Icon(Icons.copy, size: 18), onPressed: _copyPan),
              if (_isTrusted)
                IconButton(tooltip: 'Auto-fill PAN', icon: const Icon(Icons.auto_fix_high, size: 18), onPressed: _fill),
              if (widget.profiles.length > 1)
                IconButton(
                  tooltip: 'Next person',
                  icon: const Icon(Icons.skip_next),
                  onPressed: () {
                    setState(() => _current = (_current + 1) % widget.profiles.length);
                    if (_isTrusted) _controller.reload();
                  },
                ),
            ]),
          ),
        Expanded(
          child: _isTrusted
              ? WebViewWidget(controller: _controller)
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_outlined, size: 48, color: Colors.amber),
                        const SizedBox(height: 16),
                        const Text(
                          'Unverified Registrar Portal',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The registrar link (${widget.registrar.url}) is not an approved registrar domain. In-app navigation and PAN autofill are disabled for security.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _openExternal,
                          icon: const Icon(Icons.open_in_browser),
                          label: const Text('Open in External Browser'),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        if (widget.ipo != null && p != null)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              child: Row(children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _record(AllotmentOutcome.allotted),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Allotted', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _record(AllotmentOutcome.notAllotted),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Not allotted', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ),
          ),
      ]),
    );
  }
}

