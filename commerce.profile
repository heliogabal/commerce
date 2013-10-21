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
