import 'package:contact_list/search_contact.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contact_list/contact_list.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loadingBtn = false;
  bool loading = true;
  bool isNameEmpty = false;
  bool isPhoneEmpty = false;

  static final contactBox = Hive.box('contact');
  List<Map<String, dynamic>> allContacts = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchContactData();
    requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: SearchContact(contactData: allContacts));
            },
            icon: const Icon(
              Icons.search,
              size: 30,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Visibility(
          visible: !loading,
          replacement: const Center(child: CircularProgressIndicator()),
          child: allContacts.isEmpty
              ? const Center(
                  child: Text(
                    "No Contacts to Display!",
                    style: TextStyle(fontSize: 15),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 350,
                          child: ListView.builder(
                              itemCount: allContacts.length,
                              itemBuilder: (context, index) {
                                return buildContact(
                                    id: index, name: allContacts[index]['name']);
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddNewTeam();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }


  Future<void> requestPermissions() async {
    final PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
    } else {}
  }

  void addNewContact() async {
    setState(() {
      loadingBtn = true;
    });
    var temp = await contactBox.get('contact_list');

    Map<String, dynamic> value = {
      "name": nameController.text,
      "phone": phoneNumberController.text,
    };

    temp.add(value);
    await contactBox.put('contact_list', temp);
    fetchContactData();

    nameController.text = '';
    phoneNumberController.text = '';
  }

  void fetchContactData() async {
    setState(() {
      loading = true;
    });
    var tempContacts = await contactBox.get('contact_list');

    setState(() {
      allContacts = List<Map<String, dynamic>>.from(
        tempContacts.map((dynamic element) {
          return Map<String, dynamic>.from(element);
        }),
      );
    });

    setState(() {
      loading = false;
    });
  }

  String getShortName(String name) {
    List<String> result = name.split(" ");
    String shortName = "N/A";

    if (result.length >= 2) {
      shortName = "${result[0][0]}${result[1][0]}";
    } else if (result.length == 1) {
      shortName = result[0][0];
    }

    return shortName;
  }

  void _showAddNewTeam() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Add New Contact",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      nameController.text = "";
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.close)),
              ],
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Name"),
                      Container(
                        width: 260,
                        height: 40,
                        margin: const EdgeInsets.only(top: 2),
                        child: TextFormField(
                          controller: nameController,
                          onTap: () {
                            setState(() {
                              isNameEmpty = false;
                            });
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                            hintText: 'Name',
                            filled: true,
                            fillColor: Color.fromRGBO(228, 226, 226, 0.6),
                            contentPadding: EdgeInsets.all(5),
                          ),
                        ),
                      ),
                      isNameEmpty
                          ? const Text(
                              'Name Can\'t be empty',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                              ),
                            )
                          : const SizedBox(),
                      Container(
                        margin: const EdgeInsets.only(
                          top: 15,
                        ),
                        child: const Text("Phone"),
                      ),
                      Container(
                        width: 260,
                        height: 40,
                        margin: const EdgeInsets.only(top: 2, bottom: 5),
                        child: TextFormField(
                          controller: phoneNumberController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Phone';
                            } else {
                              return null;
                            }
                          },
                          onTap: () {
                            setState(() {
                              // nameExists = false;
                            });
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                            hintText: 'Phone',
                            filled: true,
                            fillColor: Color.fromRGBO(228, 226, 226, 0.6),
                            contentPadding: EdgeInsets.all(5),
                            // errorText: nameExists ? 'Name Already Exists': '',
                          ),
                        ),
                      ),
                      isPhoneEmpty
                          ? const Text(
                              'Phone Can\'t be empty',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100.0,
                    height: 40.0,
                    margin: const EdgeInsets.only(left: 0),
                    child: ElevatedButton(
                      onPressed: loadingBtn
                          ? null
                          : () {
                              setState(() {
                                if (nameController.text == '') {
                                  isNameEmpty = true;
                                } else {
                                  isNameEmpty = false;
                                }
                                if (phoneNumberController.text == '') {
                                  isPhoneEmpty = true;
                                } else {
                                  isPhoneEmpty = false;
                                }
                              });

                              if (!isNameEmpty && !isPhoneEmpty) {
                                addNewContact();
                                loadingBtn = false;
                                Navigator.of(context).pop();
                              }
                            },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                      ),
                      child: Visibility(
                        visible: !loadingBtn,
                        replacement: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        child: const Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      nameController.text = "";
                      phoneNumberController.text = "";
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      },
    );
  }

  Widget buildContact({required int id, required name}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) {
              return ContactList(cId: id, contactData: allContacts);
            },
          ));
        },
        onLongPress: () {
          _showDeleteBox(context, id);
        },
        child: ListTile(
          visualDensity: const VisualDensity(horizontal: -4, vertical: 4),
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: Colors.black12,
          contentPadding: const EdgeInsets.only(
              left: 2.0, right: 8.0, top: 0.0, bottom: 0.0),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  width: 1.5,
                  color: Colors.black54,
                ),
                color: Colors.orangeAccent,
            ),
            alignment: Alignment.center,
            margin: const EdgeInsets.only(left: 10),
            child: Text(
              getShortName(name),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 17),
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _showDeleteBox(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.blue,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Do you want to delete this Contact ?',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        allContacts.removeAt(index);
                      });
                      await contactBox.put('contact_list', allContacts);
                      Navigator.pop(context);
                    },
                    child: const Text('Yes'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('No'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

