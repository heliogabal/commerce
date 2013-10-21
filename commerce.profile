<?php

/**
 * Implements hook_image_default_styles().
 */
function commerce_image_default_styles() {
  $styles = array();
  $styles['frontpage_block'] = array(
    'name' => 'frontpage_block',
    'effects' => array(
      1 => array(
        'label' => 'Scale and crop',
        'help' => 'Scale and crop will maintain the aspect-ratio of the original image, then crop the larger dimension. This is most useful for creating perfectly square thumbnails without stretching the image.',
        'effect callback' => 'image_scale_and_crop_effect',
        'dimensions callback' => 'image_resize_dimensions',
        'form callback' => 'image_resize_form',
        'summary theme' => 'image_resize_summary',
        'module' => 'image',
        'name' => 'image_scale_and_crop',
        'data' => array(
          'width' => '270',
          'height' => '305',
        ),
        'weight' => '1',
      ),
    ),
  );

  return $styles;
}

function commerce_profile_details(){
  $details['language'] = "en";
  return $details;
}

/**
 * Implements hook_form_FORM_ID_alter().
 *
 * Allows the profile to alter the site configuration form.
 */
if (!function_exists("commerce_form_install_configure_form_alter")) {
  function commerce_form_install_configure_form_alter(&$form, $form_state) {
    $form['site_information']['site_name']['#default_value'] = 'Shop';
    $form['site_information']['site_mail']['#default_value'] = 'rhalbmann@gmail.com';

  // Account information defaults
  $form['admin_account']['account']['name']['#default_value'] = 'rainer';
  $form['admin_account']['account']['mail']['#default_value'] = 'rhalbmann@gmail.com';

  // Date/time settings
  $form['server_settings']['site_default_country']['#default_value'] = 'DE';
  $form['server_settings']['date_default_timezone']['#default_value'] = 'Europe/Berlin';
  // Unset the timezone detect stuff
  unset($form['server_settings']['date_default_timezone']['#attributes']);

  // Only check for updates, no need for email notifications
  $form['update_notifications']['update_status_module']['#default_value'] = array(0);
  }
}

/**
 * Implements hook_form_alter().
 *
 * Select the current install profile by default.
 */
if (!function_exists("system_form_install_select_profile_form_alter")) {
  function system_form_install_select_profile_form_alter(&$form, $form_state) {
    foreach ($form['profile'] as $key => $element) {
      $form['profile'][$key]['#value'] = 'commerce';
    }
  }
}

function commerce_install_tasks($install_state) {
  return array(
    'commerce_install_import_locales' => array(
      'display_name' => 'Install additional languages',
      'display' => TRUE,
      'type' => 'batch',
      'run' => INSTALL_TASK_RUN_IF_NOT_COMPLETED,
    )
  );
    // Determine whether translation import tasks will need to be performed.
  $needs_translations = count($install_state['locales']) > 1 && !empty($install_state['parameters']['locale']) && $install_state['parameters']['locale'] != 'en';

  return array(
    'commerce_import_translation' => array(
      'display_name' => st('Set up translations'),
      'display' => $needs_translations,
      'run' => $needs_translations ? INSTALL_TASK_RUN_IF_NOT_COMPLETED : INSTALL_TASK_SKIP,
      'type' => 'batch',
    ),
  );
}

function commerce_install_import_locales(&$install_state) {
  include_once DRUPAL_ROOT . '/includes/locale.inc';
  include_once DRUPAL_ROOT . '/includes/iso.inc';
  $batch = array();
  $predefined = _locale_get_predefined_list();
  foreach (array('de') as $install_locale) {
    if (!isset($predefined[$install_locale])) {
      // Drupal does not know about this language, so we prefill its values with
      // our best guess. The user will be able to edit afterwards.
      locale_add_language($install_locale, $install_locale, $install_locale, LANGUAGE_LTR, '', '', TRUE, FALSE);
    }
    else {
      // A known predefined language, details will be filled in properly.
      locale_add_language($install_locale, NULL, NULL, NULL, '', '', TRUE, FALSE);
    }

    // Collect files to import for this language.
    $batch = array_merge($batch, locale_batch_by_language($install_locale, NULL));

  }
  if (!empty($batch)) {
      // Remember components we cover in this batch set.
      variable_set('commerce_install_import_locales', $batch['#components']);
      return $batch;
  }
}

/**
 * Implement hook_install_tasks().
 */

/**
 * Implement hook_install_tasks_alter().
 *
 * Perform actions to set up the site for this profile.
 */
function commerce_install_tasks_alter(&$tasks, $install_state) {
  // Remove core steps for translation imports.
  unset($tasks['install_import_locales']);
  unset($tasks['install_import_locales_remaining']);
}

/**
 * Installation step callback.
 *
 * @param $install_state
 * An array of information about the current installation state.
 */
function commerce_import_translation(&$install_state) {
  // Enable installation language as default site language.
  include_once DRUPAL_ROOT . '/includes/locale.inc';
  $install_locale = $install_state['parameters']['locale'];
  locale_add_language($install_locale, NULL, NULL, NULL, '', NULL, 1, TRUE);

  // Build batch with l10n_update module.
  $history = l10n_update_get_history();
  module_load_include('check.inc', 'l10n_update');
  $available = l10n_update_available_releases();
  $updates = l10n_update_build_updates($history, $available);

  module_load_include('batch.inc', 'l10n_update');
  $updates = _l10n_update_prepare_updates($updates, NULL, array());
  $batch = l10n_update_batch_multiple($updates, LOCALE_IMPORT_KEEP);
  return $batch;
}

/**
 * Provides a list of Crumbs plugins and their weights.
 */
function commerce_crumbs_get_info() {
  $crumbs = array(
    'crumbs.home_title' => 0
  );

  foreach (module_implements('commerce_crumb_info') as $module) {
    // The module-provided item might be just the name of the plugin, or it
    // might be an array in the form of $plugin_name => $weight.
    foreach (module_invoke($module, 'commerce_crumb_info') as $crumb) {
      if (is_array($crumb)) {
        $crumbs += $crumb;
      }
      else {
        $crumbs[$crumb] = count($crumbs);
      }
    }
  }

  // Add the fallback wildcard.
  $crumbs['*'] = count($crumbs);

  asort($crumbs);

  return $crumbs;
}
