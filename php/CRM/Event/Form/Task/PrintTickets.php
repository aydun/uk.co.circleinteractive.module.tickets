<?php

/**
 * Event search task for printing tickets
 */
class CRM_Event_Form_Task_PrintTickets extends CRM_Event_Form_Task {

  public $_single = FALSE;

  /**
   * Build data structures required to build the form
   */
  public function preProcess() {

    $this->_context = CRM_Utils_Request::retrieve('context', 'String', $this);

    if ($this->_context == 'view') {

      $this->_single = TRUE;
      $participantID = CRM_Utils_Request::retrieve('id', 'Positive', $this, TRUE);
      $contactID     = CRM_Utils_Request::retrieve('cid', 'Positive', $this, TRUE);

      $this->_participantIds  = array($participantID);
      $this->_componentClause = " civicrm_participant.id = $participantID ";
      $this->assign('totalSelectedParticipants', 1);

      // also set the user context to send back to view page
      $session = CRM_Core_Session::singleton();
      $session->pushUserContext(CRM_Utils_System::url('civicrm/contact/view/participant', "reset=1&action=view&id={$participantID}&cid={$contactID}"));

    }
    else {
      parent::preProcess();
    }
  }

  /**
   * Build the form
   */
  public function buildQuickForm() {

    CRM_Utils_System::setTitle(ts('Generate Event Tickets'));

    $next = 'next';
    $back = $this->_single ? 'cancel' : 'back';
    $this->addDefaultButtons(ts('Generate Ticket(s)'), $next, $back);

  }

  /**
   * process the form after the input has been submitted and validated
   */
  public function postProcess() {

    $params = $this->controller->exportValues($this->_name);
    $config = CRM_Core_Config::singleton();

    $returnProperties = CRM_Event_BAO_Query::defaultReturnProperties(CRM_Contact_BAO_Query::MODE_EVENT);
    $additionalFields = array('first_name', 'last_name', 'middle_name', 'current_employer');

    foreach ($additionalFields as $field) {
      $returnProperties[$field] = 1;
    }

    if ($this->_single) {
      $queryParams = NULL;
    }
    else {
      $queryParams = $this->get('queryParams');
    }

    $query = new CRM_Contact_BAO_Query($queryParams, $returnProperties, NULL, FALSE, FALSE, CRM_Contact_BAO_Query::MODE_EVENT);

    list($select, $from, $where, $having) = $query->query();
    if (empty($where)) {
      $where = "WHERE {$this->_componentClause}";
    }
    else {
      $where .= " AND {$this->_componentClause}";
    }

    $sortOrder = NULL;
    if ($this->get(CRM_Utils_Sort::SORT_ORDER)) {
      $sortOrder = $this->get(CRM_Utils_Sort::SORT_ORDER);
      if (!empty($sortOrder)) {
        $sortOrder = " ORDER BY $sortOrder";
      }
    }

    $queryString = "$select $from $where $having $sortOrder";

    $dao  = CRM_Core_DAO::executeQuery($queryString);
    $rows = array();
    while ($dao->fetch()) {
      $rows[$dao->participant_id] = array();
      foreach (array_keys($returnProperties) as $key) {
        $rows[$dao->participant_id][$key] = isset($dao->$key) ? $dao->$key : NULL;
      }
    }

    $no_template_warn = FALSE;
    $not_registered_warn = FALSE;
    $temp_dir         = sys_get_temp_dir();
    $ticket_temp_dir  = $temp_dir . DIRECTORY_SEPARATOR . 'civicrm_event_tickets';

    // check temp directories exist and are writable, create if necessary
    if (!is_writable($temp_dir)) {
      CRM_Core_Error::fatal(ts('Unable to generate tickets. %1 is not writable', array(1 => $temp_dir)));
    }
    if (!is_dir($ticket_temp_dir)) {
      @mkdir($ticket_temp_dir);
    }
    if (!is_dir($ticket_temp_dir)) {
      CRM_Core_Error::fatal(ts('Unable to generate tickets. Could not create temp dir inside %1', array(1 => $temp_dir)));
    }
    if (count($rows) < 2) {
      // If we're printing a single ticket, output inline to browser
      $params['output'] = 'inline';
    }
    else {
      // If we're printing more than one ticket, output as zip file

      require_once implode(
        DIRECTORY_SEPARATOR,
        array(
          CRM_Core_Config::singleton()->extensionsDir,
          'uk.co.circleinteractive.module.tickets',
          'lib',
          'pclzip.lib.php',
        )
      );

      $zipfile_path = $temp_dir . DIRECTORY_SEPARATOR . md5(microtime(TRUE)) . '.zip';
      $zip          = new PclZip($zipfile_path);
      $files_list   = array();

    }

    foreach ($rows as $row) {
      if ($row['participant_status_id'] != 1) {
        // Not registered
        $not_registered_warn = TRUE;
        continue;
      }
      // get ticket class
      if (!$className = CRM_Core_DAO::singleValueQuery("
          SELECT template_class FROM civicrm_event_tickets
          WHERE entity_type = 'event'
          AND entity_id = %1
      ", array(
        1 => array($row['event_id'], 'Positive'),
      )
      )) {
        $no_template_warn = TRUE;
        continue;
      }

      $classFile = str_replace('_', DIRECTORY_SEPARATOR, $className) . '.php';
      if (!@include_once $classFile) {
        CRM_Core_Error::fatal(ts('Ticket class file: %1 does not exist. Please verify your custom ticket files.', array(1 => $classFile)));
      }
      $ticket = new $className();

      $params['filename'] = $ticket_temp_dir . DIRECTORY_SEPARATOR .
        ts('Ticket for %1 - %2', array(
            1 => $row['event_title'],
            2 => $row['display_name'],
        )) . '.pdf';

      // bugfix - don't overwrite files of the same name in the case of multi-participant registrations,
      // append (1), (2) etc
      $i = 0;
      $filename = $params['filename'];
      while (file_exists($params['filename'])) {
        $params['filename'] = explode('.', $filename);
        array_pop($params['filename']);
        $params['filename'] = implode('.', $params['filename']);
        $params['filename'] .= ' (' . (++$i) . ').pdf';
      }

      $pdf = array(
        'participant_id'         => $row['participant_id'],
        'event_id'               => $row['event_id'],
        // 'contribution_id'        => $contribution_id,
        'filename'               => $params['filename'],
        //'additional_participants_same_person' =>
        //    isset($params['tplParams']['additional_participants_same_person']) ?
        //        $params['tplParams']['additional_participants_same_person'] : 0,
        'additional_participants_same_person' => 0,
        // 'num_participants' => $num_participants,
      );

      $ticket->create($pdf, $is_reprint = TRUE);

      if (count($rows) > 1) {
        $ticket->pdf->Output($params['filename'], 'F');
        $files_list[] = $params['filename'];
      }
      else {
        $ticket->pdf->Output($params['filename'], 'I');
      }
    }

    // pdf->Output($file, 'I') sends directly to the browser.  Handle zips
    if (count($rows) > 1 and isset($params['filename'])) {

      // create zip file
      if (!$zip->add($files_list, PCLZIP_OPT_REMOVE_ALL_PATH, PCLZIP_OPT_ADD_PATH, 'event-tickets')) {
        CRM_Core_Error::fatal(ts("Internal error. Unable to create zip file."));
      }
      // output inline to browser
      header("Content-type: application/octet-stream");
      header("Content-disposition: attachment; filename=event-tickets.zip");
      readfile($zipfile_path);

      foreach ($files_list as $file) {
        @unlink($file);
      }

      @unlink($zipfile_path);
    }

    if ($no_template_warn) {
      if (count($rows) > 1) {
        $msg = CRM_Core_Session::setStatus(ts('There were events without a ticket template selected. Some tickets were not printed as a result.'));
      }
      else {
        $msg = CRM_Core_Session::setStatus(ts('The event for the participant you selected did not have a ticket template selected. The ticket was not printed as a result.'));
        return;
      }
    }
    if ($not_registered_warn) {
      if (count($rows) > 1) {
        $msg = CRM_Core_Session::setStatus(ts('Tickets are only printed for participants who are Registered. Some of your selected participants are not Registered so some tickets were not printed.'));
      }
      else {
        $msg = CRM_Core_Session::setStatus(ts('Tickets are only printed for participants who are Registered.  Your selected participant is not Registered so some tickets were not printed.'));
        return;
      }
    }

    @rmdir($ticket_temp_dir);
    CRM_Utils_System::civiExit();
  }

}
