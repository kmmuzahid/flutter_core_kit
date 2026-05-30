import 'dart:io';

/// Run this script to delete all old legacy files from the flutter_core_kit package.
/// Usage: dart tools/cleanup.dart
void main() {
  final projectRoot = Directory.current;
  
  final filesToDelete = [
    // app_bar
    'lib/app_bar/common_app_bar.dart',
    // bottomsheet
    'lib/bottomsheet/common_draggable_bottom_sheet.dart',
    // button
    'lib/button/common_button.dart',
    'lib/button/common_radio_group.dart',
    'lib/button/common_selectable_button.dart',
    'lib/button/muiltiple_selector.dart',
    'lib/button/radio_group_form_field.dart',
    // city_state
    'lib/city_state/common_city_dropdown.dart',
    'lib/city_state/common_country_picker.dart',
    'lib/city_state/common_state_dropdown.dart',
    // commonTabBar (legacy folder)
    'lib/commonTabBar/common_tab_bar.dart',
    // container
    'lib/container/dotted_border_container.dart',
    // dialoge (legacy folder with typo)
    'lib/dialoge/common_dialog.dart',
    // dropdown
    'lib/dropdown/common_drop_down.dart',
    // form
    'lib/form/custom_form.dart',
    'lib/form/form_builder.dart',
    // image
    'lib/image/common_image.dart',
    'lib/image/image_picker/common_image_picker.dart',
    'lib/image/image_picker/common_multi_image_picker.dart',
    // list_loader
    'lib/list_loader/smart_list_loader.dart',
    'lib/list_loader/smart_staggered_loader.dart',
    'lib/list_loader/smart_tab_list_loader.dart',
    // loading
    'lib/loading/common_loader.dart',
    // network
    'lib/network/dio_service.dart',
    'lib/network/response_state.dart',
    // pop_up
    'lib/pop_up/common_alert.dart',
    'lib/pop_up/common_popup_menu.dart',
    // ratting (old folder with typo — rating/ is the new one)
    'lib/ratting/common_ratting_bar.dart',
    // screenshot
    'lib/screenshot/screenshot_priview.dart',
    // snackbar
    'lib/snackbar/snackbar.dart',
    // spotlight
    'lib/spotlight/core_spotlight.dart',
    // storage
    'lib/storage/core_kit_storage.dart',
    // text
    'lib/text/common_rich_text.dart',
    'lib/text/common_text.dart',
    // text_field
    'lib/text_field/common_date_input_text_field.dart',
    'lib/text_field/common_multiline_text_field.dart',
    'lib/text_field/common_phone_number_text_filed.dart',
    'lib/text_field/common_text_field.dart',
    'lib/text_field/validation_type.dart',
    // utils
    'lib/utils/app_log.dart',
    'lib/utils/app_utils.dart',
    'lib/utils/common_share.dart',
    'lib/utils/core_kit_string.dart',
    'lib/utils/core_screen_utils.dart',
    'lib/utils/debouncer.dart',
    'lib/utils/permission_handler_helper.dart',
    'lib/utils/permission_helper.dart',
  ];

  final dirsToDelete = [
    'lib/commonTabBar',
    'lib/dialoge',
    'lib/ratting',
  ];

  int deleted = 0;
  int failed = 0;

  print('🧹 Cleaning up legacy files...\n');

  for (final relativePath in filesToDelete) {
    final file = File('${projectRoot.path}/$relativePath');
    if (file.existsSync()) {
      try {
        file.deleteSync();
        print('  ✅ Deleted: $relativePath');
        deleted++;
      } catch (e) {
        print('  ❌ Failed to delete: $relativePath ($e)');
        failed++;
      }
    } else {
      print('  ⚠️  Not found (skipped): $relativePath');
    }
  }

  print('\n🗑️  Removing empty legacy directories...\n');
  for (final relativePath in dirsToDelete) {
    final dir = Directory('${projectRoot.path}/$relativePath');
    if (dir.existsSync()) {
      try {
        dir.deleteSync(recursive: true);
        print('  ✅ Deleted dir: $relativePath');
        deleted++;
      } catch (e) {
        print('  ❌ Failed to delete dir: $relativePath ($e)');
        failed++;
      }
    } else {
      print('  ⚠️  Dir not found (skipped): $relativePath');
    }
  }

  print('\n══════════════════════════════════════════');
  print('  ✅ Deleted: $deleted items');
  if (failed > 0) print('  ❌ Failed:  $failed items');
  print('══════════════════════════════════════════');
  print('Done! Run `fvm dart analyze` to verify no errors.\n');
}
