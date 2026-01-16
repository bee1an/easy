import 'package:flutter/material.dart';
import 'package:easy/core/router/app_router.dart';
import 'package:easy/core/theme/app_theme.dart';
import 'package:easy/service/app_identity_service.dart';

class AppIdentityPage extends StatefulWidget {
  const AppIdentityPage({super.key});

  @override
  State<AppIdentityPage> createState() => _AppIdentityPageState();
}

class _AppIdentityPageState extends State<AppIdentityPage> {
  late Future<AppIdentity> _future;

  @override
  void initState() {
    super.initState();
    _future = AppIdentityService.instance.fetch();
  }

  void _reload() {
    setState(() {
      _future = AppIdentityService.instance.fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => AppRouter.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('App Identity'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<AppIdentity>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final identity = snapshot.data ?? const AppIdentity.unsupported();
          if (!identity.isSupported) {
            return _buildMessage(
              context,
              title: 'Not Supported',
              message: identity.errorMessage ?? 'Unsupported platform',
            );
          }

          if (identity.errorMessage != null) {
            return _buildMessage(
              context,
              title: 'Failed to Load',
              message: identity.errorMessage!,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildCard(
                context,
                children: [
                  _buildRow('Team ID', identity.teamId),
                  const SizedBox(height: 12),
                  _buildRow('Bundle ID', identity.bundleId),
                  const SizedBox(height: 12),
                  _buildRow('App ID', identity.appId),
                ],
              ),
              const SizedBox(height: 16),
              _buildAppGroupsCard(context, identity.appGroups),
              const SizedBox(height: 16),
              Text(
                'The App ID is derived from Team ID + Bundle ID.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMutedColor(context),
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildRow(String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SelectableText(
            value ?? 'Unavailable',
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }

  Widget _buildAppGroupsCard(BuildContext context, List<AppGroupInfo> groups) {
    if (groups.isEmpty) {
      return _buildCard(
        context,
        children: [
          Text(
            'App Groups',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'No app groups found in provisioning profile.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMutedColor(context),
                ),
          ),
        ],
      );
    }

    return _buildCard(
      context,
      children: [
        Text('App Groups', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        for (final group in groups) ...[
          _buildGroupRow(group),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildGroupRow(AppGroupInfo group) {
    final status = group.isAvailable ? 'Available' : 'Unavailable';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          group.id,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        const SizedBox(height: 4),
        Text(
          status,
          style: TextStyle(
            color: group.isAvailable ? Colors.green : Colors.orange,
          ),
        ),
        if (group.containerUrl != null) ...[
          const SizedBox(height: 4),
          SelectableText(
            group.containerUrl!,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ],
      ],
    );
  }

  Widget _buildMessage(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
