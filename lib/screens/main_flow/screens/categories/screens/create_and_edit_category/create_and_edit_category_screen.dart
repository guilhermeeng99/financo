import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/screens/main_flow/screens/categories/screens/create_and_edit_category/create_and_edit_category_bloc.dart';
import 'package:financo/screens/main_flow/screens/categories/screens/create_and_edit_category/create_and_edit_category_model.dart';

enum CreateAndEditCategoryPopUpType { create, edit }

class CreateAndEditCategoryPopUpArgs {
  CreateAndEditCategoryPopUpArgs({required this.type, this.category});

  final CategoryData? category;
  final CreateAndEditCategoryPopUpType type;
}

class CreateAndEditCategoryPopUp extends HookWidget {
  const CreateAndEditCategoryPopUp(this.args, {super.key});

  final CreateAndEditCategoryPopUpArgs args;

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      if (args.type == CreateAndEditCategoryPopUpType.edit) {
        createAndEditCategoryBloc.initializeWithCategoryData(args.category!);
      }

      return null;
    }, [args.type, args.category]);

    return CWPopUp(
      title: args.type == CreateAndEditCategoryPopUpType.edit
          ? context.t.edit_category
          : context.t.new_category,
      centerContent: Container(
        width: 400,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          spacing: 30,
          children: [
            if (args.type != CreateAndEditCategoryPopUpType.edit) const _Type(),
            const _Name(),
            const _SubCategory(),
          ],
        ),
      ),
      bottomContent: Align(
        alignment: const Alignment(0.9, 0),
        child: CWSquareButton(
          onTap: () => createAndEditCategoryModel.onTapSave(args.category),
        ),
      ),
    );
  }
}

class _Name extends HookWidget {
  const _Name();

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();

    useEffect(() {
      controller.text = createAndEditCategoryBloc.name.value;
      return null;
    }, [createAndEditCategoryBloc.name.value]);

    return TextField(
      controller: controller,
      onChanged: (value) => createAndEditCategoryBloc.name.value = value,
      cursorColor: Theme.of(context).textTheme.titleMedium?.color,
      cursorHeight: 22,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(bottom: 10),
        hintText: '${context.t.name}*',
        hintStyle: TextStyle(
          color: Theme.of(context).customColors.secondaryTextColor,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _Type extends StatelessWidget {
  const _Type();

  @override
  Widget build(BuildContext context) {
    return CWPopUpItemTitle(
      title: context.t.type,
      child: Obx(() {
        final selectedType =
            createAndEditCategoryBloc.selectedCategoryType.value;
        return SizedBox(
          width: double.infinity,
          child: DropdownButton<CategoryType>(
            value: selectedType,
            onChanged: (CategoryType? value) {
              if (value != null) {
                createAndEditCategoryBloc.selectedCategoryType.value = value;
              }
            },
            isExpanded: true,
            dropdownColor: Theme.of(context).scaffoldBackgroundColor,
            style: const TextStyle(fontSize: 18),
            underline: const CWPopUpUnderLine(),
            items: CategoryType.values.map((CategoryType type) {
              return DropdownMenuItem<CategoryType>(
                value: type,
                child: Text(type.title(context)),
              );
            }).toList(),
          ),
        );
      }),
    );
  }
}

class _SubCategory extends StatelessWidget {
  const _SubCategory();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedParentId = createAndEditCategoryBloc.parentCategoryId.value;
      final availableParents =
          createAndEditCategoryBloc.availableParentCategories;

      return SizedBox(
        width: double.infinity,
        child: DropdownButton<int?>(
          value: selectedParentId,
          onChanged: (int? value) {
            createAndEditCategoryBloc.parentCategoryId.value = value;
          },
          isExpanded: true,
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          style: const TextStyle(fontSize: 18),
          underline: const CWPopUpUnderLine(),
          hint: Text(
            context.t.subcategory_of,
            style: TextStyle(
              color: Theme.of(context).customColors.secondaryTextColor,
              fontSize: 16,
            ),
          ),
          items: [
            ...availableParents.map((CategoryData category) {
              return DropdownMenuItem<int?>(
                value: category.id,
                child: Text(category.name),
              );
            }),
          ],
        ),
      );
    });
  }
}
