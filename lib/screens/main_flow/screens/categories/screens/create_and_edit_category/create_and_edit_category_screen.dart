import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/screens/main_flow/screens/categories/screens/create_and_edit_category/create_and_edit_category_bloc.dart';
import 'package:financo/screens/main_flow/screens/categories/screens/create_and_edit_category/create_and_edit_category_model.dart';

enum CreateAndEditCategoryPopUpType { create, edit }

class CreateAndEditCategoryPopUpArgs {
  CreateAndEditCategoryPopUpArgs({
    required this.type,
    this.category,
    this.parentCategoryId,
  });

  final CategoryData? category;
  final CreateAndEditCategoryPopUpType type;
  final int? parentCategoryId;
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
      if (args.parentCategoryId != null) {
        createAndEditCategoryBloc.initializeSubCategoryFromCategory(
          args.parentCategoryId!,
        );
      }

      return null;
    }, [args.type, args.category, args.parentCategoryId]);

    return CWPopUp(
      title: args.type == CreateAndEditCategoryPopUpType.edit
          ? context.t.categories.edit_category
          : context.t.categories.new_category,
      centerContent: Container(
        width: 400,
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Column(
          children: [
            if (args.type != CreateAndEditCategoryPopUpType.edit &&
                args.parentCategoryId == null)
              const _Type(),
            const _Name(),
            const _ParentCategory(),
          ],
        ),
      ),
      bottomContent: Align(
        alignment: const Alignment(0.9, 0),
        child: CWSquareButton(
          onTap: () =>
              createAndEditCategoryModel.onTapSave(args.category, context),
        ),
      ),
    );
  }
}

class _Name extends HookWidget {
  const _Name();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final name = createAndEditCategoryBloc.name;
      final nameError = createAndEditCategoryBloc.formErrors.value.name;

      return CWTextField(
        hintText: '${context.t.common.labels.name}*',
        initialValue: name,
        onChanged: (value) => createAndEditCategoryBloc.updateName(value),
        error: nameError,
      );
    });
  }
}

class _Type extends StatelessWidget {
  const _Type();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedType = createAndEditCategoryBloc.selectedCategoryType;
      return CWDropdownField<FinancialType>(
        title: context.t.common.labels.type,
        value: selectedType,
        items: FinancialType.values,
        isExpanded: true,
        onChanged: (FinancialType? value) {
          if (value != null) {
            createAndEditCategoryBloc..updateCategoryType(value)
            ..updateParentCategoryId(null)
            ..loadAvailableParentCategories();
          }
        },
        itemBuilder: (FinancialType type, BuildContext context) {
          return Text(type.title(context));
        },
      );
    });
  }
}

class _ParentCategory extends StatelessWidget {
  const _ParentCategory();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = <CategoryData?>[
        null,
        ...createAndEditCategoryBloc.availableParentCategories,
      ];

      return CWDropdownField<CategoryData?>(
        value: createAndEditCategoryBloc.validatedParentCategoryId != null
            ? createAndEditCategoryBloc.availableParentCategories
                  .firstWhereOrNull(
                    (cat) =>
                        cat.id ==
                        createAndEditCategoryBloc.validatedParentCategoryId,
                  )
            : null,
        items: items,
        isExpanded: true,
        onChanged: (CategoryData? category) {
          createAndEditCategoryBloc.updateParentCategoryId(category?.id);
        },
        itemBuilder: (CategoryData? category, BuildContext context) {
          if (category == null) {
            return Text(
              context.t.categories.validation.uncategorized_parent,
              style: TextStyle(
                color: Theme.of(context).customColors.secondaryTextColor,
                fontStyle: FontStyle.italic,
              ),
            );
          }
          return Text(category.name);
        },
      );
    });
  }
}
