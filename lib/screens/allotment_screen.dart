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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFBFDBFE),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFDBEAFE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.badge_outlined, color: Color(0xFF2563EB), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add PAN cards for 1-tap allotment check',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Check allotment for family & friends at once. Stored locally.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white70 : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => showPanDialog(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
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
                  color: isDark ? const Color(0xFF111827) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  title: Text(
                    ipo.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Allotment ${ipo.allotmentDate != null ? dateFmt.format(ipo.allotmentDate!) : "—"} · Listing ${ipo.listingDate != null ? dateFmt.format(ipo.listingDate!) : "—"} · ${ipo.registrar}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B),
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
                                  ? const Color(0xFF10B981).withValues(alpha: .12)
                                  : (isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$allotted/${results.length} Allotted',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: allotted > 0
                                    ? const Color(0xFF10B981)
                                    : (isDark ? Colors.white70 : const Color(0xFF475569)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AllotmentCheckScreen(ipo: ipo)),
                  ),
                ),
              );
            }),
          const SectionHeader('Registrar portals'),
          ...AppConfig.registrars.map((r) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111827) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.language, size: 16, color: Color(0xFF059669)),
                  ),
                  title: Text(
                    r.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  trailing: const Icon(Icons.open_in_new, size: 14, color: Color(0xFF94A3B8)),
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
          child: Text(
            profile.name.isEmpty ? '?' : profile.name[0].toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2563EB), fontSize: 13),
          ),
        ),
        title: Text(
          profile.name,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
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
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(existing == null ? 'Add PAN' : 'Edit PAN'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name'), textCapitalization: TextCapitalization.words),
            TextField(
              controller: pan,
              decoration: InputDecoration(labelText: 'PAN number', hintText: 'ABCDE1234F', errorText: error),
              textCapitalization: TextCapitalization.characters,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]'))],
            ),
            TextField(controller: app, decoration: const InputDecoration(labelText: 'Application no. (optional)')),
            TextField(controller: dp, decoration: const InputDecoration(labelText: 'DP ID / Client ID (optional)')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
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
            child: const Text('Save'),
          ),
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          // Sleek light trading container summary box (Replaces dark navy container)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                _Count('Allotted', allotted, const Color(0xFF10B981)),
                Container(height: 32, width: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                _Count('Not allotted', notAllotted, const Color(0xFFEF4444)),
                Container(height: 32, width: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                _Count('Pending', pendingCount, const Color(0xFFF59E0B)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111827) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.business_center_outlined, size: 14, color: isDark ? Colors.white60 : const Color(0xFF64748B)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Registrar: ${ipo.registrar}  •  Allotment Date: ${ipo.allotmentDate != null ? dateFullFmt.format(ipo.allotmentDate!) : 'TBA'}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_add_alt_1, size: 32, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No PAN added yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add PAN cards of family & friends to check everyone in one go.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: () => showPanDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add PAN', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            )
          else ...[
            SizedBox(
              width: double.infinity,
              height: 42,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: s.checkingAllotment
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
                icon: s.checkingAllotment
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.search, size: 18),
                label: Text(
                  s.allotmentService.supportsAutoCheck
                      ? 'Check all ${s.profiles.length} PANs'
                      : 'Open registrar & check',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
            if (!s.allotmentService.supportsAutoCheck)
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 4),
                child: Text(
                  'Registrar sites require CAPTCHA verification. The app auto-fills each PAN so you can easily solve CAPTCHA and submit.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            ...s.profiles.map((p) {
              final r = results[p.id];
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111827) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  leading: _OutcomeIcon(r?.outcome ?? AllotmentOutcome.unknown),
                  title: Text(
                    p.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            p.pan,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : const Color(0xFF475569),
                            ),
                          ),
                        ),
                        if (r?.sharesAllotted != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${r!.sharesAllotted} shares',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        if (r != null)
                          Text(
                            'Checked ${timeAgo(r.checkedAt)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                            ),
                          ),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<AllotmentOutcome>(
                    tooltip: 'Record result',
                    icon: const Icon(Icons.edit_note, size: 20, color: Color(0xFF94A3B8)),
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
          title: Text('Shares allotted to ${p.name}'),
          content: TextField(controller: c, keyboardType: TextInputType.number, autofocus: true),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, int.tryParse(c.text) ?? defaultLot), child: const Text('Save')),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
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
    final (icon, color, bg) = switch (outcome) {
      AllotmentOutcome.allotted => (
          Icons.check_circle_rounded,
          const Color(0xFF10B981),
          const Color(0xFF10B981).withValues(alpha: .12)
        ),
      AllotmentOutcome.notAllotted => (
          Icons.cancel_rounded,
          const Color(0xFFEF4444),
          const Color(0xFFEF4444).withValues(alpha: .12)
        ),
      AllotmentOutcome.pending => (
          Icons.hourglass_top_rounded,
          const Color(0xFFF59E0B),
          const Color(0xFFF59E0B).withValues(alpha: .12)
        ),
      AllotmentOutcome.unknown => (
          Icons.help_outline_rounded,
          const Color(0xFF94A3B8),
          const Color(0xFF94A3B8).withValues(alpha: .12)
        ),
    };

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 18),
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

  PanProfile? get _profile => widget.profiles.isEmpty ? null : widget.profiles[_current];

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
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
      ))
      ..loadRequest(Uri.parse(widget.registrar.url));
  }

  Future<void> _fill() async {
    final p = _profile;
    if (p == null) return;
    try {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.registrar.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Open in browser',
            onPressed: _openExternal,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _controller.reload),
        ],
        bottom: _loading ? const PreferredSize(preferredSize: Size.fromHeight(3), child: LinearProgressIndicator()) : null,
      ),
      body: Column(children: [
        if (p != null)
          Container(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    '${_current + 1}/${widget.profiles.length} · ${p.name}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    p.pan,
                    style: const TextStyle(fontSize: 12, letterSpacing: 1, color: Color(0xFF2563EB), fontWeight: FontWeight.w700),
                  ),
                ]),
              ),
              IconButton(tooltip: 'Copy PAN', icon: const Icon(Icons.copy, size: 18), onPressed: _copyPan),
              IconButton(tooltip: 'Auto-fill PAN', icon: const Icon(Icons.auto_fix_high, size: 18), onPressed: _fill),
              if (widget.profiles.length > 1)
                IconButton(
                  tooltip: 'Next person',
                  icon: const Icon(Icons.skip_next),
                  onPressed: () {
                    setState(() => _current = (_current + 1) % widget.profiles.length);
                    _controller.reload();
                  },
                ),
            ]),
          ),
        Expanded(child: WebViewWidget(controller: _controller)),
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

