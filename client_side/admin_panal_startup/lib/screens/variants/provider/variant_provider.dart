import '../../../models/variant_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/api_response.dart';
import '../../../models/variant.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';

class VariantsProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addVariantsFormKey = GlobalKey<FormState>();
  TextEditingController variantCtrl = TextEditingController();
  VariantType? selectedVariantType;
  Variant? variantForUpdate;




  VariantsProvider(this._dataProvider);


  //TODO: should complete addVariant
  addVariant() async {
    try {
      Map<String, dynamic> variant = {
        'name' : variantCtrl.text,
        'variantTypeId' : selectedVariantType?.sId,
      };
      final response = await service.addItem(endpointUrl: 'variants', itemData: variant);

      if(response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if(apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          _dataProvider.getAllVariant();
          print("Variant added");
        }else {
          SnackBarHelper.showErrorSnackBar('Failed to add Variant: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch(e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('An  error  occurred: $e');
      rethrow;
    }
  }

  //TODO: should complete updateVariant
  updateVariant() async {
    try {
      if (variantForUpdate != null) {
        Map<String, dynamic> variant = {
          'name' : variantCtrl.text,
          'variantTypeId' : selectedVariantType?.sId,
        };
        final response = await service.updateItem(endpointUrl: 'variants', itemId: variantForUpdate?.sId ?? '', itemData: variant);
        if ( response.isOk) {
          ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
          if ( apiResponse.success == true) {
            clearFields();
            SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
            print('Variant Updated');
            _dataProvider.getAllVariant();
          } else {
            SnackBarHelper.showErrorSnackBar(' Failed to add Variant: ${apiResponse.message}');
          }
        } else {
          SnackBarHelper.showErrorSnackBar(' Error ${response.body?['message'] ?? response.statusText}');
        }
      }
    } catch (e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    }
  }

  //TODO: should complete submitVariant
  submitVariant() {
    if(variantForUpdate == null) {
      addVariant();
    } else {
      updateVariant();
    }
  }

  //TODO: should complete deleteVariant
  deleteVariant(Variant variant) async {
    try {
      Response response = await service.deleteItem(endpointUrl: 'variants', itemId: variant.sId ?? '');
      if( response.isOk ) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if( apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('Variant Deleted Successfully');
          _dataProvider.getAllVariant();
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  setDataForUpdateVariant(Variant? variant) {
    if (variant != null) {
      variantForUpdate = variant;
      variantCtrl.text = variant.name ?? '';
      selectedVariantType =
          _dataProvider.variantTypes.firstWhereOrNull((element) => element.sId == variant.variantTypeId?.sId);
    } else {
      clearFields();
    }
  }

  clearFields() {
    variantCtrl.clear();
    selectedVariantType = null;
    variantForUpdate = null;
  }

  void updateUI() {
    notifyListeners();
  }
}
