import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
    final s = context.watch<AppState>();
    final checkable = s.ipos
        .where((i) => i.status == IpoStatus.closed || i.status == IpoStatus.listed)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('IPO Allotment')),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'add-pan',
        onPressed: () => showPanDialog(context),
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          SectionHeader('Family & friends (${s.profiles.length} PAN${s.profiles.length == 1 ? '' : 's'})',
              action: 'Add PAN', onAction: () => showPanDialog(context)),
          if (s.profiles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Add PAN cards to check allotment for everyone at once'),
                  subtitle: const Text('PAN numbers are stored only on this device.'),
                  onTap: () => showPanDialog(context),
                ),
              ),
            )
          else
            ...s.profiles.map((p) => _ProfileTile(profile: p)),
          SectionHeader('Check allotment status'),
          if (checkable.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('No IPO has closed recently. Allotment can be checked after the issue closes.'),
            )
          else
            ...checkable.map((ipo) {
              final results = s.allotmentsForIpo(ipo.id);
              final allotted = results.where((r) => r.outcome == AllotmentOutcome.allotted).length;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: ListTile(
                  title: Text(ipo.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    'Allotment ${dateFmt.format(ipo.allotmentDate)} · Listing ${dateFmt.format(ipo.listingDate)} · ${ipo.registrar}'
                    '${results.isNotEmpty ? '\n$allotted of ${results.length} allotted' : ''}',
                  ),
                  isThreeLine: results.isNotEmpty,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => AllotmentCheckScreen(ipo: ipo))),
                ),
              );
            }),
          const SectionHeader('Registrar portals'),
          ...AppConfig.registrars.map((r) => ListTile(
                dense: true,
                leading: const Icon(Icons.language, size: 20),
                title: Text(r.name),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => RegistrarWebView(registrar: r, profiles: s.profiles))),
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
    final masked = '${profile.pan.substring(0, 5)}••••${profile.pan.substring(9)}';
    return ListTile(
      leading: CircleAvatar(child: Text(profile.name.isEmpty ? '?' : profile.name[0].toUpperCase())),
      title: Text(profile.name),
      subtitle: Text(masked + (profile.dpId != null ? ' · DP ${profile.dpId}' : '')),
      trailing: PopupMenuButton<String>(
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
    final s = context.watch<AppState>();
    final registrar = AllotmentService.registrarFor(ipo);
    final results = {for (final r in s.allotmentsForIpo(ipo.id)) r.profileId: r};
    final allotted = results.values.where((r) => r.outcome == AllotmentOutcome.allotted).length;
    final notAllotted = results.values.where((r) => r.outcome == AllotmentOutcome.notAllotted).length;

    return Scaffold(
      appBar: AppBar(title: Text('${ipo.name} allotment', maxLines: 1, overflow: TextOverflow.ellipsis)),
      bottomNavigationBar: const BannerAdWidget(),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                _Count('Allotted', allotted, const Color(0xFF16A34A)),
                _Count('Not allotted', notAllotted, const Color(0xFFDC2626)),
                _Count('Pending', s.profiles.length - allotted - notAllotted, Colors.orange),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          Text('Registrar: ${ipo.registrar} · Allotment date ${dateFullFmt.format(ipo.allotmentDate)}',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
          const SizedBox(height: 12),
          if (s.profiles.isEmpty)
            EmptyState(
              icon: Icons.person_add_alt_1,
              title: 'No PAN added yet',
              subtitle: 'Add PAN cards of family & friends to check everyone in one go.',
              action: FilledButton(onPressed: () => showPanDialog(context), child: const Text('Add PAN')),
            )
          else ...[
            Row(children: [
              Expanded(
                child: FilledButton.icon(
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
                                        registrar: registrar, profiles: s.profiles, ipo: ipo)));
                          }
                        },
                  icon: s.checkingAllotment
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.search),
                  label: Text(s.allotmentService.supportsAutoCheck
                      ? 'Check all ${s.profiles.length} PANs'
                      : 'Open registrar & check'),
                ),
              ),
            ]),
            if (!s.allotmentService.supportsAutoCheck)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Registrar sites use a CAPTCHA, so the app auto-fills each PAN and you tap Submit. Record the result below for each person.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 12),
            ...s.profiles.map((p) {
              final r = results[p.id];
              return Card(
                child: ListTile(
                  leading: _OutcomeIcon(r?.outcome ?? AllotmentOutcome.unknown),
                  title: Text(p.name),
                  subtitle: Text([
                    p.pan,
                    if (r?.sharesAllotted != null) '${r!.sharesAllotted} shares',
                    if (r?.note != null) r!.note!,
                    if (r != null) 'Checked ${timeAgo(r.checkedAt)}',
                  ].join(' · ')),
                  trailing: PopupMenuButton<AllotmentOutcome>(
                    tooltip: 'Record result',
                    icon: const Icon(Icons.edit_note),
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
                                  registrar: registrar, profiles: [p], ipo: ipo))),
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
      final c = TextEditingController(text: ipo.lotSize.toString());
      shares = await showDialog<int>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Shares allotted to ${p.name}'),
          content: TextField(controller: c, keyboardType: TextInputType.number, autofocus: true),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, int.tryParse(c.text) ?? ipo.lotSize), child: const Text('Save')),
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
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text('$count', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ]),
      );
}

class _OutcomeIcon extends StatelessWidget {
  const _OutcomeIcon(this.outcome);
  final AllotmentOutcome outcome;

  @override
  Widget build(BuildContext context) => switch (outcome) {
        AllotmentOutcome.allotted => const Icon(Icons.check_circle, color: Color(0xFF16A34A)),
        AllotmentOutcome.notAllotted => const Icon(Icons.cancel, color: Color(0xFFDC2626)),
        AllotmentOutcome.pending => const Icon(Icons.hourglass_top, color: Colors.orange),
        AllotmentOutcome.unknown => const Icon(Icons.help_outline, color: Colors.grey),
      };
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
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) {
          setState(() => _loading = false);
          _fill();
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
          sharesAllotted: o == AllotmentOutcome.allotted ? ipo.lotSize : null,
        ));
    if (_current < widget.profiles.length - 1) {
      setState(() => _current++);
      _controller.reload();
    } else if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _profile;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.registrar.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _controller.reload),
        ],
        bottom: _loading ? const PreferredSize(preferredSize: Size.fromHeight(3), child: LinearProgressIndicator()) : null,
      ),
      body: Column(children: [
        if (p != null)
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${_current + 1}/${widget.profiles.length} · ${p.name}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(p.pan, style: const TextStyle(fontSize: 12, letterSpacing: 1)),
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
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                    onPressed: () => _record(AllotmentOutcome.allotted),
                    icon: const Icon(Icons.check),
                    label: const Text('Allotted'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
                    onPressed: () => _record(AllotmentOutcome.notAllotted),
                    icon: const Icon(Icons.close),
                    label: const Text('Not allotted'),
                  ),
                ),
              ]),
            ),
          ),
      ]),
    );
  }
}
