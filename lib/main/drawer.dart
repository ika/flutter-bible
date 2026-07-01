part of 'page.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  /// A helper method to handle navigation elegantly
  void _navigateTo(
    BuildContext context,
    String routeName, {
    int? cacheSelector,
    bool refresh = false,
  }) {
    //1. Close the drawer immediately
    Navigator.pop(context);

    // 2. Perform any global state updates
    if (cacheSelector != null) {
      Globals.cacheSelector = cacheSelector;
    }

    // 3. Delay the push slightly for a smoother transition if needed
    // (Wait for the drawer animation to clear the screen)
    Future.delayed(Duration(milliseconds: Globals.navigatorDelay), () {
      if (!context.mounted) return;

      Navigator.pushNamed(context, routeName).then((_) {
        if (refresh) {
          Globals.refreshNotifier.refresh();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 150.0,
            child: DrawerHeader(
              decoration: const BoxDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // Stretch so children can take the full width; we'll align each
                // child individually so 'Index' is left-aligned and the
                // version string is centered.
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Index',
                      style: TextStyle(
                        color: color,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildItem(
            context,
            Icons.bookmark,
            'Bookmarks',
            '/cache',
            cacheSelector: 1,
            refresh: true,
          ),
          _buildItem(
            context,
            Icons.highlight,
            'Highlights',
            '/cache',
            cacheSelector: 2,
            refresh: true,
          ),
          _buildItem(context, Icons.search, 'Search', '/search'),
          _buildItem(
            context,
            Icons.font_download,
            'Fonts',
            '/fonts',
            refresh: true,
          ),
          _buildItem(context, Icons.palette, 'Themes', '/themes'),
          _buildItem(context, Icons.book, 'Versions', '/versions'),
          _buildItem(context, Icons.backup, 'Backup', '/backup'),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    IconData icon,
    String title,
    String route, {
    int? cacheSelector,
    bool refresh = false,
  }) {
    final color = Theme.of(context).colorScheme.primary;
    return ListTile(
      leading: Icon(icon, color: color),
      trailing: Icon(Icons.keyboard_arrow_right, color: color),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      onTap: () => _navigateTo(
        context,
        route,
        cacheSelector: cacheSelector,
        refresh: refresh,
      ),
    );
  }
}
