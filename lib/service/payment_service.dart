import 'package:flutter/material.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';

class PaymentService {
  static Future<void> payNow(BuildContext context, double totalAmount, String orderId) async {
    Sslcommerz sslcommerz = Sslcommerz(
      initializer: SSLCommerzInitialization(
        currency: SSLCurrencyType.BDT,
        product_category: "Food",
        sdkType: SSLCSdkType.TESTBOX,
        store_id: "mobil5fe45035efe16",
        store_passwd: "mobil5fe45035efe16@ssl",
        total_amount: totalAmount,
        tran_id: orderId,
      ),
    );

    try {
      SSLCTransactionInfoModel result = await sslcommerz.payNow();
      if (result is PlatformException) {
        debugPrint(result.status);
      } else {
        if (result.status!.toLowerCase() == "failed") {
          print('Transaction is Failed....');
          await Fluttertoast.showToast(
              msg: "Transaction is Failed....",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          print(
              "Transaction is ${result.status} and Amount is ${result.amount}");
          await Fluttertoast.showToast(
            msg:
            "Transaction is ${result.status} and Amount is ${result.amount}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
