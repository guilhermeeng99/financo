import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/profile/profile_model.dart';

ProfileBloc get profileBloc => Modular.get<ProfileBloc>();

class ProfileBloc extends GetxController {
  final RxBool _isDeleting = false.obs;
  bool get isDeleting => _isDeleting.value;

  Future<void> deleteAllData(BuildContext context) async {
    try {
      _isDeleting.value = true;
      await profileModel.deleteAllData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.profile.delete_success),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.profile.delete_error(error: e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isDeleting.value = false;
    }
  }
}
