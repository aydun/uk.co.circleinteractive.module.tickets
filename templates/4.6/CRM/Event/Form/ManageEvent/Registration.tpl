{*
 +--------------------------------------------------------------------+
 | CiviCRM version 4.6                                                |
 +--------------------------------------------------------------------+
 | Copyright CiviCRM LLC (c) 2004-2015                                |
 +--------------------------------------------------------------------+
 | This file is a part of CiviCRM.                                    |
 |                                                                    |
 | CiviCRM is free software; you can copy, modify, and distribute it  |
 | under the terms of the GNU Affero General Public License           |
 | Version 3, 19 November 2007 and the CiviCRM Licensing Exception.   |
 |                                                                    |
 | CiviCRM is distributed in the hope that it will be useful, but     |
 | WITHOUT ANY WARRANTY; without even the implied warranty of         |
 | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.               |
 | See the GNU Affero General Public License for more details.        |
 |                                                                    |
 | You should have received a copy of the GNU Affero General Public   |
 | License and the CiviCRM Licensing Exception along                  |
 | with this program; if not, contact CiviCRM LLC                     |
 | at info[AT]civicrm[DOT]org. If you have questions about the        |
 | GNU Affero General Public License or the licensing of CiviCRM,     |
 | see the CiviCRM license FAQ at http://civicrm.org/licensing        |
 +--------------------------------------------------------------------+
*}
{if $addProfileBottomAdd OR $addProfileBottom}
  <td scope="row" class="label"
      width="20%">{if $addProfileBottomAdd }{$form.additional_custom_post_id_multiple[$profileBottomNumAdd].label}
    {else}{$form.custom_post_id_multiple[$profileBottomNum].label}{/if}</td>
  <td>{if $addProfileBottomAdd }{$form.additional_custom_post_id_multiple[$profileBottomNumAdd].html}{else}{$form.custom_post_id_multiple[$profileBottomNum].html}{/if}
    &nbsp;<span class='profile_bottom_link_remove'><a href="#" class="crm-hover-button crm-button-rem-profile"
                                                      data-addtlPartc="{$addProfileBottomAdd}"><span
          class="icon ui-icon-trash"></span>{ts}remove profile{/ts}</a></span>&nbsp;&nbsp;<span
      class='profile_bottom_link'>&nbsp;<a href="#" class="crm-hover-button crm-button-add-profile"><span
          class="icon ui-icon-plus"></span>{ts}add another profile (bottom of page){/ts}</a></span>
    {if $addProfileBottomAdd }
      <div
        class="description">{ts}Change this if you want to use a different profile for additional participants.{/ts}</div>
    {else}
      <div
        class="description">{ts}Include additional fields on this registration form by selecting and configuring a CiviCRM Profile to be included at the bottom of the page.{/ts}</div>
    {/if}
    <br/><span class="profile-links"></span>
  </td>
{else}
{assign var=eventID value=$id}
  <div id="help">
    {ts}If you want to provide an Online Registration page for this event, check the first box below and then complete the fields on this form.{/ts}
    {help id="id-event-reg"}
  </div>
<div class="crm-block crm-form-block crm-event-manage-registration-form-block">
<div class="crm-submit-buttons">
{include file="CRM/common/formButtons.tpl" location="top"}
</div>

<div id="register">
  <table class="form-layout">
    <tr class="crm-event-manage-registration-form-block-is_online_registration">
      <td class="label">{$form.is_online_registration.label}</td>
      <td>{$form.is_online_registration.html}
        <span class="description">{ts}Online registration enabled?{/ts}</span>
      </td>
    </tr>
  </table>
</div>
<div class="spacer"></div>
<div id="registration_blocks">
<table class="form-layout-compressed">

  <tr class="crm-event-manage-registration-form-block-registration_link_text">
    <td scope="row" class="label"
        width="20%">{$form.registration_link_text.label} {if $action == 2}{include file='CRM/Core/I18n/Dialog.tpl' table='civicrm_event' field='registration_link_text' id=$eventID}{/if}</td>
    <td>{$form.registration_link_text.html} {help id="id-link_text"}</td>
  </tr>
  {if !$isTemplate}
    <tr class="crm-event-manage-registration-form-block-registration_start_date">
      <td scope="row" class="label" width="20%">{$form.registration_start_date.label}</td>
      <td>{include file="CRM/common/jcalendar.tpl" elementName=registration_start_date}</td>
    </tr>
    <tr class="crm-event-manage-registration-form-block-registration_end_date">
      <td scope="row" class="label" width="20%">{$form.registration_end_date.label}</td>
      <td>{include file="CRM/common/jcalendar.tpl" elementName=registration_end_date}</td>
    </tr>
  {/if}
  <tr class="crm-event-manage-registration-form-block-is_multiple_registrations">
    <td scope="row" class="label" width="20%">{$form.is_multiple_registrations.label}</td>
    <td>{$form.is_multiple_registrations.html} {help id="id-allow_multiple"}</td>
  </tr>
  <tr class="crm-event-manage-registration-form-block-allow_same_participant_emails">
    <td scope="row" class="label" width="20%">{$form.allow_same_participant_emails.label}</td>
    <td>{$form.allow_same_participant_emails.html} {help id="id-allow_same_email"}</td>
  </tr>
  <tr class="crm-event-manage-registration-form-block-dedupe_rule_group_id">
    <td scope="row" class="label" width="20%">{$form.dedupe_rule_group_id.label}</td>
    <td>{$form.dedupe_rule_group_id.html} {help id="id-dedupe_rule_group_id"}</td>
  </tr>
  <tr class="crm-event-manage-registration-form-block-requires_approval">
    {if $form.requires_approval}
      <td scope="row" class="label" width="20%">{$form.requires_approval.label}</td>
      <td>{$form.requires_approval.html} {help id="id-requires_approval"}</td>
    {/if}
  </tr>
  <tr id="id-approval-text" class="crm-event-manage-registration-form-block-approval_req_text">
    {if $form.approval_req_text}
      <td scope="row" class="label"
          width="20%">{$form.approval_req_text.label} {if $action == 2}{include file='CRM/Core/I18n/Dialog.tpl' table='civicrm_event' field='approval_req_text' id=$eventID}{/if}</td>
      <td>{$form.approval_req_text.html}</td>
    {/if}
  </tr>
  <tr class="crm-event-manage-registration-form-block-expiration_time">
    <td scope="row" class="label" width="20%">{$form.expiration_time.label}</td>
    <td>{$form.expiration_time.html|crmAddClass:four} {help id="id-expiration_time"}</td>
  </tr>
</table>
<div class="spacer"></div>

{*Registration Block*}
<fieldset id="registration" class="crm-collapsible {if $defaultsEmpty}collapsed{/if}">
  <legend class="collapsible-title">{ts}Registration Screen{/ts}</legend>
  <div id="registration_screen">
    <table class="form-layout-compressed">
      <tr class="crm-event-manage-registration-form-block-intro_text">
        <td scope="row" class="label"
            width="20%">{$form.intro_text.label} {if $action == 2}{include file='CRM/Core/I18n/Dialog.tpl' table='civicrm_event' field='intro_text' id=$eventID}{/if}</td>
        <td>{$form.intro_text.html}
          <div
            class="description">{ts}Introductory message / instructions for online event registration page (may include HTML formatting tags).{/ts}</div>
        </td>
      </tr>
      <tr class="crm-event-manage-registration-form-block-footer_text">
        <td scope="row" class="label"
            width="20%">{$form.footer_text.label} {if $action == 2}{include file='CRM/Core/I18n/Dialog.tpl' table='civicrm_event' field='footer_text' id=$eventID}{/if}</td>
        <td>{$form.footer_text.html}
          <div class="description">{ts}Optional footer text for registration screen.{/ts}</div>
        </td>
      </tr>
    </table>
    <table class="form-layout-compressed">
      <tr class="crm-event-manage-registration-form-block-custom_pre_id">
        <td scope="row" class="label" width="20%">{$form.custom_pre_id.label}</td>
        <td>{$form.custom_pre_id.html}
          <div
            class="description">{ts}Include additional fields on this registration form by selecting and configuring a CiviCRM Profile to be included at the top of the page (immediately after the introductory message).{/ts}{help id="event-profile"}</div>
        </td>
      </tr>
      <tr id="profile_post" class="crm-event-manage-registration-form-block-custom_post_id">
        <td scope="row" class="label" width="20%">{$form.custom_post_id.label}</td>
        <td>{$form.custom_post_id.html}
          <div
            class="description">{ts}Include additional fields on this registration form by selecting and configuring a CiviCRM Profile to be included at the bottom of the page.{/ts}</div>
          &nbsp;<span class='profile_bottom_link_main {if $profilePostMultiple}hiddenElement{/if}'>&nbsp;<a href="#"
class="crm-hover-button crm-button-add-profile"><span
                class="icon ui-icon-plus"></span>{ts}add another profile (bottom of page){/ts}</a></span>
          <br/>
        </td>
      </tr>

      {if $profilePostMultiple}
        {foreach from=$profilePostMultiple item=profilePostId key=profilePostNum name=profilePostIdName}
          <tr id="custom_post_id_multiple_{$profilePostNum}_wrapper"
              class='crm-event-manage-registration-form-block-custom_post_multiple'>
            <td scope="row" class="label" width="20%">{$form.custom_post_id_multiple.$profilePostNum.label}</td>
            <td>{$form.custom_post_id_multiple.$profilePostNum.html}
              &nbsp;
              <span class='profile_bottom_link_remove'>
                <a href="#" class="crm-hover-button crm-button-rem-profile">
                  <span class="icon ui-icon-trash"></span>{ts}remove profile{/ts}
                </a>
              </span>
              &nbsp;&nbsp;
              <span class='profile_bottom_link' {if !$smarty.foreach.profilePostIdName.last} style="display: none"{/if}>
                <a href="#" class="crm-hover-button crm-button-add-profile">
                  <span class="icon ui-icon-plus"></span>
                  {ts}add another profile (bottom of page){/ts}
                </a>
              </span>
              <br/><span class="profile-links"></span>
            </td>
          </tr>
        {/foreach}
      {/if}
    </table>
    <table class="form-layout-compressed">
      <tr id="additional_profile_pre" class="crm-event-manage-registration-form-block-additional_custom_pre_id">
        <td scope="row" class="label" width="20%">{$form.additional_custom_pre_id.label}</td>
        <td>{$form.additional_custom_pre_id.html}
              <div
                class="description">{ts}Change this if you want to use a different profile for additional participants.{/ts}</div>
          <br/><span class="profile-links"></span>
        </td>
      </tr>
      <tr id="additional_profile_post" class="crm-event-manage-registration-form-block-additional_custom_post_id">
        <td scope="row" class="label" width="20%">{$form.additional_custom_post_id.label}</td>
        <td>{$form.additional_custom_post_id.html}
          <div
            class="description">{ts}Change this if you want to use a different profile for additional participants.{/ts}
          </div>
          &nbsp;<span class='profile_bottom_add_link_main{if $profilePostMultipleAdd} hiddenElement{/if}'><a
              href="#" class="crm-hover-button crm-button-add-profile"><span
                class="icon ui-icon-plus"></span>{ts}add another profile (bottom of page){/ts}</a></span>
          <br/><span class="profile-links"></span>
        </td>
      </tr>
      {if $profilePostMultipleAdd}
        {foreach from=$profilePostMultipleAdd item=profilePostIdA key=profilePostNumA name=profilePostIdAName}
          <tr id='additional_custom_post_id_multiple_{$profilePostNumA}_wrapper'
              class='crm-event-manage-registration-form-block-additional_custom_post_multiple'>
            <td scope="row" class="label"
                width="20%">{$form.additional_custom_post_id_multiple.$profilePostNumA.label}</td>
            <td>{$form.additional_custom_post_id_multiple.$profilePostNumA.html}
              &nbsp;
              <span class='profile_bottom_add_link_remove'>
                <a href="#" class="crm-hover-button crm-button-rem-profile">
                  <span class="icon ui-icon-trash"></span>{ts}remove profile{/ts}
                </a>
              </span>
              <span class='profile_bottom_add_link' {if !$smarty.foreach.profilePostIdAName.last} style="display: none"{/if}>
                <a href="#" class="crm-hover-button crm-button-add-profile">
                  <span class="icon ui-icon-plus"></span>
                  {ts}add another profile (bottom of page){/ts}
                </a>
              </span>
              <br/><span class="profile-links"></span>
            </td>
          </tr>
        {/foreach}
      {/if}
    </table>
  </div>
</fieldset>

{*Confirmation Block*}
<fieldset id="confirm" class="crm-collapsible {if $defaultsEmpty}collapsed{/if}">
  <legend class="collapsible-title">{ts}Confirmation Screen{/ts}</legend>
  {if !$is_monetary}
    <table class="form-layout-compressed">
      <tr class="crm-event-manage-registration-form-block-is_confirm_enabled">
        <td scope="row" class="label" width="20%">{$form.is_confirm_enabled.label}</td>
        <td>{$form.is_confirm_enabled.html}
          <div class="description">{ts}Optionally hide the confirmation screen for free events.{/ts}</div>
        </td>
      </tr>
    </table>
  {/if}

  <div id="confirm_screen_settings">
    <table class="form-layout-compressed">
      <tr class="crm-event-manage-registration-form-block-confirm_title">
        <td scope="row" class="label" width="20%">{$form.confirm_title.label} <span
            class="marker">*</span> {if $action == 2}{include file='CRM/Core/I18n/Dialog.tpl' table='civicrm_event' field='confirm_title' id=$eventID}{/if}
        </td>
        <td>{$form.confirm_title.html}<br/>
                <span
                  class="description">{ts}Page title for screen where user reviews and confirms their registration information.{/ts}</span>
        </td>
      </tr>
      <tr class="crm-event-manage-registration-form-block-confirm_text">
        <td scope="row" class="label"
            width="20%">{$form.confirm_text.label} {if $action == 2}{include file='CRM/Core/I18n/Dialog.tpl' table='civicrm_event' field='confirm_text' id=$eventID}{/if}</td>
        <td>{$form.confirm_text.html}
          <div class="description">{ts}Optional instructions / message for Confirmation screen.{/ts}</div>
        </td>
      </tr>
      <tr class="crm-event-manage-registration-form-block-confirm_footer_text">
        <td scope="row" class="label"
            width="20%">{$form.confirm_footer_text.label} {if $action == 2}{include file='CRM/Core/I18n/Dialog.tpl' table='civicrm_event' field='confirm_footer_text' id=$eventID}{/if}</td>
        <td>{$form.confirm_footer_text.html}
          <div class="description">{ts}Optional page footer text for Confirmation screen.{/ts}</div>
        </td>
      </tr>
    </table>
  </div>
</fieldset>

{*ThankYou Block*}
<fieldset id="thankyou" class="crm-collapsible {if $defaultsEmpty}collapsed{/if}">
  <legend class="collapsible-title">{ts}Thank-you Screen{/ts}</legend>
  <table class="form-layout-compressed">
    <tr class="crm-event-manage-registration-form-block-confirm_thankyou_title">
      <td scope="row" class="label" width="20%">{$form.thankyou_title.label} <span
          class="marker">*</span> {if $action == 2}{include file='CRM/Core/I18n/Dialog.tpl' table='civicrm_event' field='thankyou_title' id=$eventID}{/if}
      </td>
      <td>{$form.thankyou_title.html}
        <div class="description">{ts}Page title for registration Thank-you screen.{/ts}</div>
      </td>
    </tr>
    <tr class="crm-event-manage-registration-form-block-confirm_thankyou_text">
      <td scope="row" class="label"
          width="20%">{$form.thankyou_text.label} {if $action == 2}{include file='CRM/Core/I18n/Dialog.tpl' table='civicrm_event' field='thankyou_text' id=$eventID}{/if}</td>
      <td>{$form.thankyou_text.html}
        <div
          class="description">{ts}Optional message for Thank-you screen (may include HTML formatting).{/ts}</div>
      </td>
    </tr>
    <tr class="crm-event-manage-registration-form-block-confirm_thankyou_footer_text">
      <td scope="row" class="label"
          width="20%">{$form.thankyou_footer_text.label} {if $action == 2}{include file='CRM/Core/I18n/Dialog.tpl' table='civicrm_event' field='thankyou_footer_text' id=$eventID}{/if}</td>
      <td>{$form.thankyou_footer_text.html}
        <div
          class="description">{ts}Optional footer text for Thank-you screen (often used to include links to other pages/activities on your site).{/ts}</div>
      </td>
    </tr>
  </table>
</fieldset>

{* Confirmation Email Block *}
<fieldset id="mail" class="crm-collapsible {if $defaultsEmpty}collapsed{/if}">
  <legend class="collapsible-title">{ts}Confirmation Email{/ts}</legend>
  <div>
    <table class="form-layout-compressed">
      <tr class="crm-event-manage-registration-form-block-is_email_confirm">
        <td scope="row" class="label" width="20%">{$form.is_email_confirm.label}</td>
        <td>{$form.is_email_confirm.html}<br/>
          <span
            class="description">{ts}Do you want a registration confirmation email sent automatically to the user? This email includes event date(s), location and contact information. For paid events, this email is also a receipt for their payment.{/ts}</span>
        </td>
      </tr>
    </table>
    <div id="confirmEmail">
      <table class="form-layout-compressed">
        <tr class="crm-event-manage-registration-form-block-confirm_email_text">
          <td scope="row" class="label"
              width="20%">{$form.confirm_email_text.label} {if $action == 2}{include file='CRM/Core/I18n/Dialog.tpl' table='civicrm_event' field='confirm_email_text' id=$eventID}{/if}</td>
          <td>{$form.confirm_email_text.html}<br/>
            <span
              class="description">{ts}Additional message or instructions to include in confirmation email.{/ts}</span>
          </td>
        </tr>
        <tr class="crm-event-manage-registration-form-block-confirm_from_name">
          <td scope="row" class="label" width="20%">{$form.confirm_from_name.label} <span
              class="marker">*</span> {if $action == 2}{include file='CRM/Core/I18n/Dialog.tpl' table='civicrm_event' field='confirm_from_name' id=$eventID}{/if}
          </td>
          <td>{$form.confirm_from_name.html}<br/>
            <span class="description">{ts}FROM name for email.{/ts}</span>
          </td>
        </tr>
        <tr class="crm-event-manage-registration-form-block-confirm_from_email">
          <td scope="row" class="label" width="20%">{$form.confirm_from_email.label} <span class="marker">*</span></td>
          <td>{$form.confirm_from_email.html}<br/>
            <span
              class="description">{ts}FROM email address (this must be a valid email account with your SMTP email service provider).{/ts}</span>
          </td>
        </tr>
        <tr class="crm-event-manage-registration-form-block-cc_confirm">
          <td scope="row" class="label" width="20%">{$form.cc_confirm.label}</td>
          <td>{$form.cc_confirm.html}<br/>
            <span
              class="description">{ts}You can notify event organizers of each online registration by specifying one or more email addresses to receive a carbon copy (cc). Multiple email addresses should be separated by a comma (e.g. jane@example.org, paula@example.org).{/ts}</span>
          </td>
        </tr>
        <tr class="crm-event-manage-registration-form-block-bcc_confirm">
          <td scope="row" class="label" width="20%">{$form.bcc_confirm.label}</td>
          <td>{$form.bcc_confirm.html}<br/>
            <span
              class="description">{ts}You may specify one or more email addresses to receive a blind carbon copy (bcc) of the confirmation email. Multiple email addresses should be separated by a comma (e.g. jane@example.org, paula@example.org).{/ts}</span>
          </td>
        </tr>

        <tr class="crm-event-manage-registration-form-block-ticket_attach">
         <td scope="row" class="label" width="20%">{$form.ticket_attach.label}</td>
         <td>{$form.ticket_attach.html}
            <span class="preview-link"><a target="_blank" href="{crmURL p='civicrm/admin/event/ticket/preview' h=0}" onclick="this.href = cj('#preview-url').val() + cj('#ticket_attach').val() + '&id={$eventId}'; return true;">Preview</a></span>
            <span class="preview-text">Preview</span><br />
            <span class="description">{ts}Specify a format for the event ticket, or 'None' to send no ticket.{/ts}</span>
            <input id="preview-url" type="hidden" value="{crmURL p='civicrm/admin/event/ticket/preview' q='reset=1&template=' h=0}" />
         </td>
        </tr>
        {literal}<script type="text/javascript">formatChange();</script>{/literal}

      </table>
    </div>
  </div>
</fieldset>
</div> {*end of div registration_blocks*}
    </div>
  <div class="crm-submit-buttons">
    {include file="CRM/common/formButtons.tpl" location="bottom"}
  </div>
  {include file="CRM/common/showHide.tpl"}
{include file="CRM/common/showHideByFieldValue.tpl"
trigger_field_id    ="is_online_registration"
trigger_value       =""
target_element_id   ="registration_blocks"
target_element_type ="block"
field_type          ="radio"
invert              = 0
}
{if !$is_monetary}
{include file="CRM/common/showHideByFieldValue.tpl"
trigger_field_id    ="is_confirm_enabled"
trigger_value       =""
target_element_id   ="confirm_screen_settings"
target_element_type ="block"
field_type          ="radio"
invert              = 0
}
{/if}
{include file="CRM/common/showHideByFieldValue.tpl"
trigger_field_id    ="is_email_confirm"
trigger_value       =""
target_element_id   ="confirmEmail"
target_element_type ="block"
field_type          ="radio"
invert              = 0
}
{include file="CRM/common/showHideByFieldValue.tpl"
trigger_field_id    ="is_multiple_registrations"
trigger_value       =""
target_element_id   ="additional_profile_pre|additional_profile_post"
target_element_type ="table-row"
field_type          ="radio"
invert              = 0
}
{if $form.requires_approval}
{include file="CRM/common/showHideByFieldValue.tpl"
    trigger_field_id    ="requires_approval"
    trigger_value       =""
    target_element_id   ="id-approval-text"
    target_element_type ="table-row"
    field_type          ="radio"
    invert              = 0
}
{/if}

{*include profile link function*}
{include file="CRM/common/buildProfileLink.tpl"}

<script type="text/javascript">
{literal}    (function($, _) { // Generic Closure

    $(".crm-submit-buttons input").click( function() {
      $(".dedupenotify .ui-notify-close").click();
    });

    var profileBottomCount = Number({/literal}{$profilePostMultiple|@count}{literal});
    var profileBottomCountAdd = Number({/literal}{$profilePostMultipleAdd|@count}{literal});

    function addBottomProfile( e ) {
        var urlPath;
        e.preventDefault();

        var addtlPartc = $(this).data('addtlPartc');

        if ($(this).closest("td").children("input").attr("name").indexOf("additional_custom_post") > -1 || addtlPartc) {
            profileBottomCountAdd++
            urlPath = CRM.url('civicrm/event/manage/registration', { addProfileBottomAdd: 1, addProfileNumAdd: profileBottomCountAdd, snippet: 4 } ) ;
        } else {
            profileBottomCount++;
            urlPath = CRM.url('civicrm/event/manage/registration', { addProfileBottom: 1 , addProfileNum : profileBottomCount, snippet: 4 } ) ;
        }

        $(this).closest('tbody').append('<tr class="additional_profile"></tr>');
        var $el = $(this).closest('tbody').find('tr:last');
        $el.load(urlPath, function() { $(this).trigger('crmLoad') });
        $(this).closest(".profile_bottom_link_main, .profile_bottom_link, .profile_bottom_add_link_main").hide();
        $el.find(".profile_bottom_link_main, .profile_bottom_link, .profile_bottom_add_link_main").show();
    }

    function removeBottomProfile( e ) {
        e.preventDefault();

        $(e.target).closest('tr').hide().find('.crm-profile-selector').val('');
        $(e.target).closest('tbody').find('tr:visible:last .profile_bottom_link_main,tr:visible:last .profile_bottom_add_link, tr:visible:last .profile_bottom_link, tr:visible:last .profile_bottom_add_link_main').show();
    }

    var
      strSameAs = '{/literal}{ts escape='js'}- same as for main contact -{/ts}{literal}',
      strSelect = '{/literal}{ts escape='js'}- select -{/ts}{literal}';

    $('#crm-container').on('crmLoad', function() {
        var $container = $("[id^='additional_profile_'],.additional_profile").not('.processed').addClass('processed');
        $container.find(".crm-profile-selector-select select").each( function() {
            var $select = $(this);
            var selected = $select.find(':selected').val(); //cache the default
            $select.find('option[value=""]').remove();
            $select.prepend('<option value="">'+strSameAs+'</option>');
            if ($select.closest('tr').is(':not([id*="_pre"])')) {
               $select.prepend('<option value="">'+strSelect+'</option>');
            }
            $select.find('option[value="'+selected+'"]').attr('selected', 'selected'); //restore default
        });
    });

$(function($) {

    var allow_multiple = $("#is_multiple_registrations");
    if ( !allow_multiple.prop('checked') ) {
        $('#additional_profile_pre,#additional_profile_post').hide();
    }
    allow_multiple.change( function( ) {
        if ( !$(this).prop('checked') ) {
            $("#additional_custom_pre_id,#additional_custom_post_id").val('');
            $(".crm-event-manage-registration-form-block-additional_custom_post_multiple").hide();
            $('#additional_profile_pre,#additional_profile_post').hide();
        } else {
            $(".crm-event-manage-registration-form-block-additional_custom_post_multiple").show();
            $('#additional_profile_pre,#additional_profile_post').show();
        }

    });

    $('#registration_blocks').on('click', '.crm-button-add-profile', addBottomProfile);
    $('#registration_blocks').on('click', '.crm-button-rem-profile', removeBottomProfile);

    $('#crm-container').on('crmLoad', function(e) {
        $('tr[id^="additional_profile"] input[id^="additional_custom_"]').change(function(e) {
            var $input = $(e.target);
            if ( $input.val() == '') {
                var $selected = $input.closest('tr').find('.crm-profile-selector-select :selected');
                if ($selected.text() == strSelect) { $input.val('none'); }
            }
        });
    });

}); // END onReady
}(CRM.$, CRM._)); //Generic Closure
{/literal}
</script>
{/if}
