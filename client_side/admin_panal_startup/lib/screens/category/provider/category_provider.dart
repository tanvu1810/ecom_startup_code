import 'dart:io';
import 'dart:math';
import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'dart:developer';

import '../../../services/http_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addCategoryFormKey = GlobalKey<FormState>();
  TextEditingController categoryNameCtrl = TextEditingController();
  Category? categoryForUpdate;


  File? selectedImage;
  XFile? imgXFile;


  CategoryProvider(this._dataProvider);

  //TODO: should complete addCategory
  addCategory() async {
    try {
      if(selectedImage == null) {
        SnackBarHelper.showErrorSnackBar("Please choose a image !");
        return; //? Stop the program eviction
      }
      Map<String, dynamic> formDataMap = {
        'name': categoryNameCtrl.text,
        'image': 'no_data', //? image path will add from server side
      };

      final FormData form = await createFormData(imgXFile: imgXFile, formData: formDataMap);
      final response = await service.addItem(endpointUrl: 'categories', itemData: form);
      if(response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if(apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          _dataProvider.getAllCategory();
          print("category added");
        }else {
          SnackBarHelper.showErrorSnackBar('Failed to add category: ${apiResponse.message}');
        }
      }
      else {
        SnackBarHelper.showErrorSnackBar('Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch(e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('An  error  occurred: $e');
      rethrow;
    }
  }
  //TODO: should complete updateCategory
  updateCategory() async {
    try {
      Map<String, dynamic> formDataMap = {
        'name' : categoryNameCtrl.text,
        'image' : categoryForUpdate?.image ?? '',
      };
      final FormData form = await createFormData(imgXFile: imgXFile, formData: formDataMap);
      final response = await service.updateItem(endpointUrl: 'categories', itemId: categoryForUpdate?.sId ?? '', itemData: form);
      if(response.isOk) {
        ApiResponse apiResponse =ApiResponse.fromJson(response.body, null);
        if(apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          print('category added');
          _dataProvider.getAllCategory();
        } else {
          SnackBarHelper.showErrorSnackBar('Failed to add category: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('An error  occurred: $e');
      rethrow;
    }
  }
  //TODO: should complete submitCategory
  submitCategory() {
    if(categoryForUpdate == null) {
      addCategory();
    } else {
      updateCategory();
    }
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      imgXFile = image;
      notifyListeners();
    }
  }

  //TODO: should complete deleteCategory
  deleteCategory(Category category) async {
    try {
      Response response = await service.deleteItem(endpointUrl: 'categories', itemId: category.sId ?? '');
      if( response.isOk ) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if( apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('Category Deleted Successfully');
          _dataProvider.getAllCategory();
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }
  //TODO: should complete setDataForUpdateCategory

  //? to create form data for sending image with body
  Future<FormData> createFormData({required XFile? imgXFile, required Map<String, dynamic> formData}) async {
    if (imgXFile != null) {
      MultipartFile multipartFile;
      if (kIsWeb) {
        String fileName = imgXFile.name;
        Uint8List byteImg = await imgXFile.readAsBytes();
        multipartFile = MultipartFile(byteImg, filename: fileName);
      } else {
        String fileName = imgXFile.path.split('/').last;
        multipartFile = MultipartFile(imgXFile.path, filename: fileName);
      }
      formData['img'] = multipartFile;
    }
    final FormData form = FormData(formData);
    return form;
  }

  //? set data for update on editing
  setDataForUpdateCategory(Category? category) {
    if (category != null) {
      clearFields();
      categoryForUpdate = category;
      categoryNameCtrl.text = category.name ?? '';
    } else {
      clearFields();
    }
  }

  //? to clear text field and images after adding or update category
  clearFields() {
    categoryNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    categoryForUpdate = null;
  }
}
