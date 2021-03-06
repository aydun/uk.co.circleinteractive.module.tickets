<?php

/*
 * Event Tickets Extension for CiviCRM - Circle Interactive 2013
 * Author: andyw@circle
 *
 * Distributed under the GNU Affero General Public License, version 3
 * http://www.gnu.org/licenses/agpl-3.0.html
 */

/**
 * Implements hook_civicrm_alterMailParams().
 */
function event_tickets_civicrm_alterMailParams(&$params, $context = NULL) {
  if (!empty($context) AND $context != "singleEmail") {
    // In 4.6 this is called once and context is null
    // In 4.7 this is called twice with contexts of 'singleMail' and 'messageTemplate'.  Only do singleEmail
    // Awkward condition construction, but avoids being tripped up if new contexts are added
    return;
  }
  static $runCount = 0;

  if ($params['groupName'] == 'msg_tpl_workflow_event') {
    $is_offline = ($params['valueName'] == 'event_offline_receipt');
    $is_online = ($params['valueName'] == 'event_online_receipt');
    if (!$is_online and !$is_offline) {
      return;
    }
    $contact_id = $params['contactId'];
    if ($is_offline) {
      // We only have the contact_id to work with, but would like a participant id.
      // We'll assume the most recent participant record for this contact is the right one ...
      $primary_participant = civicrm_api3('Participant', 'getsingle', array(
        'contact_id' => $contact_id,
        'return' => array('partipant_id', 'event_id'),
        'options' => array('sort' => "participant_id DESC", 'limit' => 1),
      ));
      $event_id = $primary_participant['event_id'];
      $primary_participant_id = $participant_id = $primary_participant['participant_id'];
      $is_additional_participant = FALSE;
    }
    if ($is_online) {
      // This gets called for primary participant as well as additionals
      // For primary participants, we send all the tickets
      // For additional participants, we send just their ticket
      $event_id = $params['tplParams']['event']['id'];
      $participant_id = $params['tplParams']['participantID'];
      $primary_participant_id = $params['tplParams']['participant']['id'];
      $is_additional_participant = ($participant_id != $primary_participant_id);
    }

    $primary_participant = civicrm_api3('Participant', 'getsingle', array(
      'participant_id' => $primary_participant_id,
    ));
    if ($primary_participant['participant_status'] != "Registered") {
      // Only send tickets if primary participant is Registered - skip for other statuses
      return;
    }

    $template_class = event_tickets_get_template_for_event($event_id);
    if (!$template_class) {
      // Nothing to do if there's no template
      return;
    }

    $event_title = civicrm_api3('Event', 'getvalue', array(
      'return' => 'event_title',
      'event_id' => $event_id,
    ));

    $participants = array($participant_id);

    if (!$is_additional_participant) {
      // Get additional participants
      // ... but I think you can't add multiple participants from an off-line signup so this is not needed
      // civicrm_api3('Participant', 'get', array('registered_by_id' => $primary_participant_id)) ... should work
      // but returns all participant.
      // Only show those that are Registered / Status_id = 1
      $dao = CRM_Core_DAO::executeQuery("
        SELECT id FROM civicrm_participant WHERE registered_by_id = %1 AND status_id = 1
        ", array(
          1 => array($participant_id, 'Positive'),
        )
      );
      while ($dao->fetch()) {
        $participants[] = $dao->id;
      }
    }

    // Find contribution, but might not be one
    // Not sure this is needed ...
    $result = civicrm_api3('ParticipantPayment', 'get', array(
      'participant_id' => $primary_participant_id,
      'return' => "contribution_id",
      'sequential' => 1,
    ));
    if ($result['count'] > 0) {
      $contribution_id = $result['values'][0]['contribution_id'];
    }
    else {
      $contribution_id = NULL;
    }

    // original online version seems to have extra complexity for unused functionality
    // around additional participant customizations
    // simplified version here:
    $params['attachments'] = array();
    $temp_files            = array();

    $ticket = new $template_class();
    $tmp_filename = sys_get_temp_dir() . DIRECTORY_SEPARATOR . md5(microtime(TRUE)) . '.pdf';

    // Loop through participants and attach all tickets to the main participant email
    $num_participants = count($participants) + 1;
    foreach ($participants as $part_id) {
      $pdf = array(
        'participant_id'         => $part_id,
        'event_id'               => $event_id,
        'contribution_id'        => $contribution_id,
        'filename'               => $tmp_filename,
        //'additional_participants_same_person' =>
        //    isset($params['tplParams']['additional_participants_same_person']) ?
        //        $params['tplParams']['additional_participants_same_person'] : 0,
        'additional_participants_same_person' => 0,
        // 'num_participants' => $num_participants,
      );
      $ticket->create($pdf, $is_additional_participant);
    }
    $temp_files[] = $pdf['filename'];

    // output to temp file (this will be deleted after it's been attached to the email)
    $ticket->pdf->Output($pdf['filename'], 'F');

    // attach the new attachment ..
    $params['attachments'] = array(array(
      'fullPath'  => $pdf['filename'],
      'mime_type' => 'application/pdf',
      'cleanName' => ts(
        'Ticket%1 for %2.pdf',
        array(
          1 => count($participants) > 1 ? 's' : '',
          2 => $event_title,
        )
      ),
      ));

    register_shutdown_function('event_tickets_cleanup', $temp_files);
    // Programmer note: to suppress sending the mail, set $params['abortMailSend'] = TRUE; and return
  }
}

/**
 * Implements hook_civicrm_buildForm().
 */
function event_tickets_civicrm_buildForm($formName, &$form) {

  //drupal_set_message('Form = <pre>' . print_r($form, TRUE) . '</pre>');

  // Load custom css/javascript on all ManageEvent forms - we need to do this because of the ajax
  // form loading mechanism - ie: any of these forms could be the entry point via which the
  // 'Registration' or 'Thankyou' form is eventually viewed
  if (array_slice(explode('_', $formName), 0, 4) === array('CRM', 'Event', 'Form', 'ManageEvent')) {

    // add custom resources
    $extension = 'uk.co.circleinteractive.module.tickets';
    CRM_Core_Resources::singleton()->addStyleFile($extension, 'css/admin-form.css');
    CRM_Core_Resources::singleton()->addScriptFile($extension, 'js/admin-form.js');

    // if we're the 'Registration' (or 'Thankyou' in the case of contributions)
    // component of one of the above set of forms, apply form customizations
    switch ($formName) {
      case 'CRM_Event_Form_ManageEvent_Registration':

        $config   = &CRM_Core_Config::singleton();
        $template = &CRM_Core_Smarty::singleton();

        // Get ticket formats
        $formats = array(0 => '-- None --') + event_tickets_load_templates();

        $selected_item = CRM_Core_DAO::singleValueQuery("
          SELECT template_class FROM civicrm_event_tickets WHERE entity_type = 'event' AND entity_id = %1
          ", array(
            1 => array($form->_id, 'Integer'),
          )) or $selected_item = 0;

        // Add formats select box

        $form->addElement('select', 'ticket_attach', ts('Ticket Format'), $formats, array('onchange' => 'formatChange();'));
        $form->setDefaults(
          array(
            'ticket_attach' => $selected_item,
          )
        );
    }
  }
}

/**
 * Implements hook_civicrm_config().
 */
function event_tickets_civicrm_config() {

  // Add our templates directory
  $template    = &CRM_Core_Smarty::singleton();
  $templateDir = __DIR__ . '/templates/' . _event_tickets_crm_version();

  if (is_array($template->template_dir)) {
    array_unshift($template->template_dir, $templateDir);
  }
  else {
    $template->template_dir = array($templateDir, $template->template_dir);
  }
  // Add our php directory to include path
  $include_path = __DIR__ . DIRECTORY_SEPARATOR . 'php' . PATH_SEPARATOR . get_include_path();
  set_include_path($include_path);
}

/**
 * Implements hook_civicrm_install().
 */
function event_tickets_civicrm_install() {
  CRM_Core_DAO::executeQuery("
    CREATE TABLE IF NOT EXISTS `civicrm_event_tickets` (
      `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
      `entity_type` varchar(32) NOT NULL,
      `entity_id` int(10) unsigned NOT NULL,
      `template_class` varchar(32) NOT NULL,
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;
  ");
}

/**
 * Implements hook_civicrm_postProcess().
 */
function event_tickets_civicrm_postProcess($formName, &$form) {

  switch ($formName) {
    // save pdf template details on ManageEvent and ContributionPage admin forms
    case 'CRM_Event_Form_ManageEvent_Registration':
    // case 'CRM_Contribute_Form_ContributionPage_ThankYou':

      if ($current_entry_id = CRM_Core_DAO::singleValueQuery("
        SELECT id
        FROM civicrm_event_tickets
        WHERE entity_type = %1
        AND entity_id = %2
        ", array(
          1 => array('event', 'String'),
          2 => array($form->get('id'), 'Integer'),
        ))
      ) {
        CRM_Core_DAO::executeQuery("
            UPDATE civicrm_event_tickets SET template_class = %1 WHERE id = %2
            ", array(
              1 => array($form->_submitValues['ticket_attach'], 'String'),
              2 => array($current_entry_id, 'Integer'),
            )
          );
      }
      else {
        CRM_Core_DAO::executeQuery("
          INSERT INTO civicrm_event_tickets (id, entity_type, entity_id, template_class) VALUES (NULL, %1, %2, %3)
          ", array(
            1 => array('event', 'String'),
            2 => array($form->get('id'), 'Integer'),
            3 => array($form->_submitValues['ticket_attach'], 'String'),
          ));
      }
      break;
  }
}

/**
 * Implements hook_civicrm_searchTasks().
 */
function event_tickets_civicrm_searchTasks($objectName, &$tasks) {

  // Add our custom 'Generate Event Tickets' task to event searches

  static $foo = 0; // just run once per form load if you don't mind, thanks.
  if ($objectName == 'event' and !$foo++) {
    $tasks[] = array(
      'title'  => ts('Generate Event Tickets'),
      'class'  => 'CRM_Event_Form_Task_PrintTickets',
      'result' => FALSE,
    );
  }
}

/**
 * Implements hook_civicrm_uninstall().
 */
function event_tickets_civicrm_uninstall() {
  // Delete template -> event mapping table
  CRM_Core_DAO::executeQuery('DROP TABLE civicrm_event_tickets');
}

/**
 * Implements hook_civicrm_xmlMenu().
 */
function event_tickets_civicrm_xmlMenu(&$files) {
  // add menu hook for ticket preview
  $files[] = dirname(__FILE__) . DIRECTORY_SEPARATOR . 'menu.xml';
}

/*
 * Helper functions
 */

/**
 * Delete any tickets on exit
 * @param  [string OR array of strings] $temp_file [temporary file to delete]
 */
function event_tickets_cleanup($temp_file) {
  if (!is_array($temp_file)) {
    $temp_file = array($temp_file);
  }
  foreach ($temp_file as $file) {
    @unlink($file);
  }
}

/**
 * Get template for given event
 * @param  [int] $event_id [event ID]
 * @return [type]           [template_class]
 */
function event_tickets_get_template_for_event($event_id) {
  return CRM_Core_DAO::singleValueQuery(
    "SELECT template_class FROM civicrm_event_tickets WHERE entity_type = 'event' AND entity_id = %1",
    array(
      1 => array($event_id, 'Integer'),
    )
  );
}

function event_tickets_load_templates() {

  $include_paths = explode(PATH_SEPARATOR, get_include_path());
  $templates     = array();

  // Iterate through include paths
  foreach ($include_paths as $include_path) {
    // Check for the existence of a CRM/Event/Ticket dir under the current include path
    $path = implode(DIRECTORY_SEPARATOR, array($include_path, 'CRM', 'Event', 'Ticket'));
    if (file_exists($path) and is_dir($path)) {
      if ($handle = opendir($path)) {
        // If found, iterate through files and note the name of any php files
        while (FALSE !== ($entry = readdir($handle))) {
          if ($entry != "." and $entry != ".." and substr($entry, -4) == '.php') {
            // 'not in array' check causes the first file found to be favoured where naming conflicts
            // exist, which is wot an include path duz innit
            if (!in_array($entry, $templates)) {
              // infer class name from filename and run 'name' method of that class
              $filename_parts        = explode('.', $entry);
              $classname             = 'CRM_Event_Ticket_' . reset($filename_parts);
              $templates[$classname] = call_user_func(array($classname, 'name'));
            }
          }
        }
        closedir($handle);
      }
    }
  }

  ksort($templates);
  return $templates;
}

/**
 * Get CiviCRM version
 */
function _event_tickets_crm_version() {
  return CRM_Utils_System::majorVersion();
}
