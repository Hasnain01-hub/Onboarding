import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as widgets;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf_builder/database/dao/FormDAO.dart';
import 'package:pdf_builder/widget/pdf/InvoicePageWidget.dart';
import 'package:intl/intl.dart';

class PdfTemplate {
  static _validateNullText(String text) {
    return text != null ? text : "";
  }

  static _buildServicesList(
      List<List<String>> list, OverallInvoice overallInvoice) {
    int length = overallInvoice.serviceDetails.length;
    int counter = 0;
    double total = 0;
    if (length > 0) {
      overallInvoice.serviceDetails.forEach((element) {
        double nettPrice;
        counter++;
        try {
          total += double.parse(element.nettPrice);
          nettPrice = double.parse(element.nettPrice);
        } on Exception {
          nettPrice = 0.00;
          print("unable to parse service no: $counter");
        }

        list.add([
          counter.toString(),
          element.serviceName.toString(),
          "${nettPrice.toString()}"
          //   NumberFormat.currency(symbol:'₹').format(nettPrice),
        ]);
      });

      return total;
    } else {
      return 0.00;
    }
  }

  static void pdfWriter(
      OverallInvoice overallInvoice, widgets.Document pdf) async {
    final ByteData bytes = await rootBundle.load("image/image.png");
    final headerImage = PdfImage.file(
      pdf.document,
      bytes: bytes.buffer.asUint8List(),
    );
    final List<List<String>> servicesList = new List();
    servicesList.add(["No", "Service", "Total Price"]);
    double totalAmountToPay = _buildServicesList(servicesList, overallInvoice);

    const twoCm = 2.0 * PdfPageFormat.cm;

    pdf.addPage(
      InvoicePage(
        //manage the position of the header from this page
        margin: widgets.EdgeInsets.fromLTRB(
            twoCm, 7.0 * PdfPageFormat.cm, twoCm, twoCm),
        headerImage: headerImage,
        build: (context) => widgets.Column(
          children: <widgets.Widget>[
            widgets.Text(
              "Invoice",
              style: widgets.TextStyle(
                  fontSize: 36, fontWeight: widgets.FontWeight.bold),
            ),
            widgets.Row(
              mainAxisAlignment: widgets.MainAxisAlignment.center,
              children: <widgets.Widget>[
                widgets.Text(
                  "Bill-No: ",
                  style: widgets.TextStyle(
                    fontSize: 24.0,
                  ),
                ),
                widgets.Padding(
                  padding: const widgets.EdgeInsets.only(top: 2),
                  child: widgets.Text(
                      _validateNullText(
                          overallInvoice.invoiceDetails.invoiceNumber),
                      style: widgets.TextStyle(
                          fontSize: 20.0,
                          fontWeight: widgets.FontWeight.normal)),
                ),
              ],
            ),
            widgets.Row(
              mainAxisAlignment: widgets.MainAxisAlignment.center,
              children: <widgets.Widget>[
                widgets.Text(
                  "Date of issue: ",
                  style: widgets.TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                widgets.Padding(
                  padding: const widgets.EdgeInsets.only(top: 2),
                  child: widgets.Text(
                      _validateNullText(
                          overallInvoice.invoiceDetails.dateOfIssue.doi),
                      style: widgets.TextStyle(
                          fontSize: 14.0,
                          fontWeight: widgets.FontWeight.normal)),
                ),
              ],
            ),
            widgets.Row(
              mainAxisAlignment: widgets.MainAxisAlignment.center,
              children: <widgets.Widget>[
                widgets.Text(
                  "Date Of Service: ",
                  style: widgets.TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                widgets.Padding(
                  padding: const widgets.EdgeInsets.only(top: 2),
                  child: widgets.Text(
                      "${_validateNullText(overallInvoice.invoiceDetails.dateOfService.firstDate)}" +
                          " - ${_validateNullText(overallInvoice.invoiceDetails.dateOfService.lastDate)}",
                      style: widgets.TextStyle(
                          fontSize: 14.0,
                          fontWeight: widgets.FontWeight.normal)),
                ),
              ],
            ),
            widgets.SizedBox(height: 2.0 * PdfPageFormat.cm),
            widgets.Row(
              mainAxisAlignment: widgets.MainAxisAlignment.spaceBetween,
              children: <widgets.Widget>[
                widgets.Column(
                    crossAxisAlignment: widgets.CrossAxisAlignment.start,
                    children: <widgets.Widget>[
                      widgets.Text(
                        "Customer Info",
                        style: widgets.TextStyle(
                            fontWeight: widgets.FontWeight.bold,
                            decoration: widgets.TextDecoration.underline),
                      ),
                      widgets.Text(
                       "Name: "+ _validateNullText(overallInvoice.contractorDetails.companyName),
                      ),
                      widgets.Text(
                       "Phone no: "+ _validateNullText(overallInvoice.contractorDetails.addressLine1),
                      ),
                      widgets.Text(
                      "Address: "+ _validateNullText(overallInvoice.contractorDetails.addressLine2),
                      ),
                      widgets.Text(
                        _validateNullText(overallInvoice.contractorDetails.addressLine3),
                      ),
                    ]),
                widgets.Column(
                    crossAxisAlignment: widgets.CrossAxisAlignment.start,
                    children: <widgets.Widget>[
                      widgets.Text(
                        "Vehicle Details",
                        style: widgets.TextStyle(
                            fontWeight: widgets.FontWeight.bold,
                            decoration: widgets.TextDecoration.underline),
                      ),
                      widgets.Text(
                       "Vehicle No: " +_validateNullText(overallInvoice.clientDetails.vehicleNo),
                      ),
                      widgets.Text(
                       "Model: "+ _validateNullText(overallInvoice.clientDetails.modelLine1),
                      ),
                      // widgets.Text(
                      //   _validateNullText(overallInvoice.clientDetails.addressLine2),
                      // ),
                      // widgets.Text(
                      //   _validateNullText(overallInvoice.clientDetails.addressLine3),
                      // ),
                    ]),
              ],
            ),
            widgets.SizedBox(height: 2.0 * PdfPageFormat.cm),
            widgets.Table.fromTextArray(context: context, data: servicesList),
            widgets.SizedBox(height: 1.0 * PdfPageFormat.cm),
            widgets.Row(children: <widgets.Widget>[
              widgets.Expanded(child: widgets.Container()),
              widgets.Row(
                mainAxisAlignment: widgets.MainAxisAlignment.center,
                children: <widgets.Widget>[
                  widgets.Text(
                    "Total: ",
                    style: widgets.TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  widgets.Padding(
                    padding: const widgets.EdgeInsets.only(top: 2),
                    child: widgets.Text("${totalAmountToPay.toString()}",
                        style: widgets.TextStyle(
                            fontSize: 18.0,
                            fontWeight: widgets.FontWeight.bold)),
                  ),
                ],
              ),
            ]),
            // widgets.SizedBox(height: 3.0 * PdfPageFormat.cm),
            // widgets.Row(
            //     mainAxisAlignment: widgets.MainAxisAlignment.spaceBetween,
            //     children: <widgets.Widget>[
            //       widgets.Column(
            //         children: <widgets.Widget>[
            //           widgets.Container(
            //             width: 4.0 * PdfPageFormat.cm,
            //             decoration: widgets.BoxDecoration(
            //                 border: widgets.BoxBorder(top: true)),
            //           ),
            //           widgets.Text(
            //             "Buyer",
            //           ),
            //         ],
            //       ),
            //       widgets.Column(
            //         children: <widgets.Widget>[
            //           widgets.Container(
            //             width: 4.0 * PdfPageFormat.cm,
            //             decoration: widgets.BoxDecoration(
            //                 border: widgets.BoxBorder(top: true)),
            //           ),
            //           widgets.Text(
            //             "Seller",
            //           ),
            //         ],
            //       )
            //     ]
            // ),
          ],
        ),
      ),
    );
  }
}