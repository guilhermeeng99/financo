import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/profile/profile_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            Text(
              t.profile.title,
            ),
            const Divider(),

            Obx(() {
              return ElevatedButton.icon(
                onPressed: profileBloc.isDeleting
                    ? null
                    : () => profileBloc.deleteAllData(context),
                icon: profileBloc.isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_forever),
                label: Text(t.profile.delete_all_data),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
