import 'package:flutter/material.dart';
import 'package:nehhdc_app/Model_Screen/APIs_Screen.dart';
import 'package:nehhdc_app/Setting_Screen/Setting_Screen.dart';

import 'package:intl/intl.dart';
import 'package:nehhdc_app/Setting_Screen/Static_Verible';

class Product_Report extends StatefulWidget {
  const Product_Report({super.key});

  @override
  State<Product_Report> createState() => _Product_ReportState();
}

class _Product_ReportState extends State<Product_Report> {
  TextEditingController searchController = TextEditingController();
  TextEditingController _endDtController = TextEditingController();
  TextEditingController _startDtController = TextEditingController();
  List<String> _weaverNames = [];
  String _selectedWeaver = '';
  DateTime selectedDate = DateTime.now();
  late DateTime FromDate;
  late DateTime ToDate;
  List<ProductView> productViewList = [];
  bool isLoading = false;
  bool weaverenable = true;
  bool searchPerformed = false;

  @override
  void initState() {
    initializeFromDate();
    super.initState();
    fetchWeavers().then((_) {
      if (_weaverNames.length == 2 && staticverible.type == 'Own') {
        setState(() {
          _selectedWeaver = _weaverNames[1];
          weaverenable = false;
        });
      }
    });
  }

  Future<void> fetchWeavers() async {
    try {
      TempWearverAPIs tempWeaverAPIs = TempWearverAPIs();
      List<String>? weaverNames = await tempWeaverAPIs.Fetchwearver(context);
      if (weaverNames != '' && weaverNames.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _weaverNames = ['Select Weaver', ...weaverNames];
          _selectedWeaver = _weaverNames[0];
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching weaver names: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void initializeFromDate() {
    if (_startDtController.text.isEmpty) {
      _startDtController.text = DateTime.now().toIso8601String();
    }
    if (_endDtController.text.isEmpty) {
      _endDtController.text = DateTime.now().toIso8601String();
    }

    FromDate = DateTime.parse(_startDtController.text);
    ToDate = DateTime.parse(_endDtController.text);
  }

  void fetchData() async {
    try {
      plaesewaitmassage(context);
      List<ProductView> itemdata =
          await GetProductwiseData(context, FromDate, ToDate, _selectedWeaver);

      setState(() {
        productViewList = itemdata;
        searchPerformed = true;
        Navigator.of(context).pop();
      });
    } catch (e) {
      print("Error fetching product data: $e");
      setState(() {
        searchPerformed = true;
      });
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectStartDate(
      BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _startDtController.text = picked.toLocal().toString().split(' ')[0];
        FromDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(
      BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _endDtController.text = picked.toLocal().toString().split(' ')[0];
        ToDate = picked;
      });
    }
  }

  void showProductDetails(BuildContext context, ProductView product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Center(
            child: Column(
              children: [
                Text(
                  "Product Details",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Divider()
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("State : ${product.state}"),
                SizedBox(height: 2),
                Text("District : ${product.district}"),
                SizedBox(height: 2),
                Text("Department : ${product.department}"),
                SizedBox(height: 2),
                Text("Type : ${product.type}"),
                SizedBox(height: 2),
                Text("Organization : ${product.organazation}"),
                SizedBox(height: 2),
                Row(
                  children: [
                    Text("Image: "),
                    if (product.image != '' && product.image.isNotEmpty)
                      InkWell(
                        child: Text(
                          "View Image",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                        onTap: () {
                          launchImageURL(product.image);
                        },
                      )
                    else
                      Text("N/A")
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Text("Video : "),
                    if (product.video != '' && product.video.isNotEmpty)
                      InkWell(
                        child: Text(
                          "View Video",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                        onTap: () {
                          launchvideosURL(product.video);
                        },
                      )
                    else
                      Text("N/A")
                  ],
                ),
                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 20),
                InkWell(
                  child: Center(
                    child: Container(
                      height: 40,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color(ColorVal),
                      ),
                      child: Center(
                        child: Text(
                          "Close",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  String formatproductName(String name) {
    if (name.length > 20) {
      return name.substring(0, 20) + '\n' + name.substring(20);
    } else {
      return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Product List",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(ColorVal),
      ),
      body: Column(
        children: [
          Container(
            height: 150,
            color: Color(ColorVal),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width / 2.2,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5)),
                          child: Center(
                            child: Text(
                              "Start Date: ${FromDate != '' ? DateFormat('dd MMM yyyy').format(FromDate) : ''}",
                              style: TextStyle(color: Color(ColorVal)),
                            ),
                          ),
                        ),
                        onTap: () {
                          _selectStartDate(context, setState);
                        },
                      ),
                      InkWell(
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width / 2.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              "End Date: ${ToDate != '' ? DateFormat('dd MMM yyyy').format(ToDate) : ''}",
                              style: TextStyle(color: Color(ColorVal)),
                            ),
                          ),
                        ),
                        onTap: () {
                          _selectEndDate(context, setState);
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isLoading)
                        Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Color(ColorVal)),
                          ),
                        )
                      else if (staticverible.type == 'Own')
                        Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(width: 0, color: Colors.grey),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              underline: SizedBox(),
                              value: _selectedWeaver,
                              items: _weaverNames.map((String weaverName) {
                                return DropdownMenuItem<String>(
                                  value: weaverName,
                                  child: Text(
                                    weaverName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      color: staticverible.type == 'Own'
                                          ? Colors.black
                                          : Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: weaverenable
                                  ? (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _selectedWeaver = newValue;
                                        });
                                      }
                                    }
                                  : null,
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(width: 0, color: Colors.white),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              underline: SizedBox(),
                              value: _selectedWeaver,
                              items: _weaverNames.map((String weaverName) {
                                return DropdownMenuItem<String>(
                                  value: weaverName,
                                  child: Text(
                                    weaverName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedWeaver = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width / 1,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color.fromARGB(255, 175, 170, 243)),
                      child: Center(child: Text("Search")),
                    ),
                    onTap: () {
                      if (_selectedWeaver == _weaverNames.first &&
                          _selectedWeaver.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              'Please select weaver name',
                            ),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        searchPerformed = true;
                      });
                      fetchData();
                    },
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: productViewList.isEmpty
                ? Center(
                    child: searchPerformed
                        ? Column(
                            children: [
                              Image.asset(
                                  'assets/Images/Data_Not_Available.jpg'),
                              Text("No Data Found"),
                            ],
                          )
                        : Image.asset('assets/Images/Nodata.jpg'),
                  )
                : ListView.separated(
                    itemCount: productViewList.length,
                    itemBuilder: (context, index) {
                      final product = productViewList[index];
                      final hasData = product.qrtextfinal.isNotEmpty &&
                          product.productname.isNotEmpty &&
                          product.wearverName.isNotEmpty;
                      return ListTile(
                        title: product.qrtextfinal.isNotEmpty
                            ? Row(
                                children: [
                                  Text('QR Label: '),
                                  Text(product.qrtextfinal),
                                ],
                              )
                            : null,
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.productname.isNotEmpty)
                              Row(
                                children: [
                                  Text('Product Name: '),
                                  Text(
                                      '${formatproductName(product.productname)}'),
                                ],
                              ),
                            if (product.wearverName.isNotEmpty)
                              Row(
                                children: [
                                  Text('Weaver Name: '),
                                  Text(product.wearverName),
                                ],
                              ),
                          ],
                        ),
                        trailing: hasData
                            ? IconButton(
                                onPressed: () {
                                  showProductDetails(context, product);
                                },
                                icon: Icon(
                                  Icons.remove_red_eye_outlined,
                                  color: Color(ColorVal),
                                ),
                              )
                            : null,
                      );
                    },
                    separatorBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Divider(),
                    ),
                  ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
