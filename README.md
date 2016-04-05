# uk.co.circleinteractive.tickets
CiviCRM event tickets extension

Usage
-----

Install Civi extension as usual.

In Event configuration, Online Registration there should be a new section
at the end to select the Ticket Format.  Select a type then click Preview
to see an example.

When Online Registration is used, the PDF ticket will be added as an
attachment to the mail.

Go to Find Participants, search and then there is an action "Generate
Event Tickets".  If one participant is selected, the PDF is sent to
the browser.  If more than one, a zip file of individual tickets is sent.

Creating new ticket templates requires extending CRM_Event_Ticket.
See CRM_Event_Ticket_BoxOffice, CRM_Event_Ticket_Default,
CRM_Event_Ticket_Example
