/**
 * Meenakshi Dairy Farms – order logger  (v3: separate cow / buffalo / total amount columns)
 *
 * 1. Open your Google Sheet ▸ Extensions ▸ Apps Script
 * 2. Delete everything, paste this, set NOTIFY_EMAIL below, Save
 * 3. Deploy ▸ Manage deployments ▸ (edit the existing one) ▸ Version: New version ▸ Deploy
 *    -- keeping the SAME deployment keeps the SAME /exec URL, so no change in the webpage.
 *    Execute as: Me   |   Who has access: Anyone
 * 4. First save will ask you to authorise MailApp — allow it.
 */

var SHEET_NAME   = 'Orders';
var NOTIFY_EMAIL = 'meenakshidairyfarms@gmail.com';   // <-- where new-order emails go ('' = no email)

var HEADERS = ['Received', 'Ref', 'Name', 'Phone', 'Address', 'Area / landmark', 'Pincode',
  'Cow litres', 'Cow amount (Rs)', 'Buffalo litres', 'Buffalo amount (Rs)', 'Total amount (Rs)',
  'Frequency', 'Start date', 'Notes', 'Language'];

function num(v) { return (v === '' || v == null || isNaN(v)) ? 0 : Number(v); }

function doPost(e) {
  try {
    var data = JSON.parse(e.postData.contents);
    var ss = SpreadsheetApp.getActiveSpreadsheet();
    var sh = ss.getSheetByName(SHEET_NAME);
    if (!sh) sh = ss.insertSheet(SHEET_NAME);

    if (sh.getLastRow() === 0) {
      sh.appendRow(HEADERS);
      sh.getRange(1, 1, 1, HEADERS.length).setFontWeight('bold');
      sh.setFrozenRows(1);
    }

    var cowL = num(data.cow_litres),  cowAmt = num(data.cow_amount);
    var bufL = num(data.buffalo_litres), bufAmt = num(data.buffalo_amount);
    var total = data.total_amount != null ? num(data.total_amount) : (cowAmt + bufAmt);

    var row = [
      new Date(),
      data.ref || '', data.name || '', data.phone || '', data.address || '', data.area || '',
      data.pincode || '',
      cowL, cowAmt, bufL, bufAmt, total,
      data.frequency || '', data.start_date || '', data.notes || '', data.language || ''
    ];
    sh.appendRow(row);

    if (NOTIFY_EMAIL) {
      try {
        MailApp.sendEmail({
          to: NOTIFY_EMAIL,
          subject: 'New milk order — ' + (data.name || '?') + ' (Rs ' + total +
            (data.frequency && data.frequency !== 'One-time' ? ' / delivery' : '') + ')',
          body:
            'Ref: ' + (data.ref || '-') + '\n' +
            'Name: ' + (data.name || '-') + '\n' +
            'Phone: ' + (data.phone || '-') + '\n' +
            'Address: ' + (data.address || '-') + '\n' +
            'Area / landmark: ' + (data.area || '-') + '\n' +
            'Pincode: ' + (data.pincode || '-') + '\n\n' +
            'Cow milk: ' + cowL + ' L  =  Rs ' + cowAmt + '\n' +
            'Buffalo milk: ' + bufL + ' L  =  Rs ' + bufAmt + '\n' +
            'TOTAL: Rs ' + total + (data.frequency && data.frequency !== 'One-time' ? ' per delivery' : '') + '\n\n' +
            'Frequency: ' + (data.frequency || '-') + '\n' +
            'Start date: ' + (data.start_date || '-') + '\n' +
            'Notes: ' + (data.notes || '-') + '\n' +
            'Language: ' + (data.language || '-') + '\n'
        });
      } catch (mailErr) { /* logging must not fail because email failed */ }
    }

    return ContentService
      .createTextOutput(JSON.stringify({ ok: true }))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (err) {
    return ContentService
      .createTextOutput(JSON.stringify({ ok: false, error: String(err) }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

// Open the Web app URL in a browser to check it's alive.
function doGet() {
  return ContentService.createTextOutput('Meenakshi order logger is running.');
}
