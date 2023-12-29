import 'package:contact_list/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ContactList extends StatefulWidget {
  final List<Map<String, dynamic>> contactData;
  final int cId;

  const ContactList({super.key, required this.contactData, required this.cId });

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {

  List<Map<String, dynamic>> contacts = [];
  int id = -1;

  static final myContact = Hive.box('contact');

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool loadingBtn = false;
  bool isNameEmpty = false;
  bool isPhoneEmpty = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    contacts = widget.contactData;
    id = widget.cId;
  }

  void updateContact() async {
    setState(() {
      loadingBtn = true;
      contacts[id]['name'] = nameController.text;
      contacts[id]['phone'] = phoneNumberController.text;
    });
    await myContact.put('contact_list', contacts);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) {
                return const MyHomePage(title: 'My Contact');
              },
            ));
          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Contact View'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blueGrey
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      contacts[id]['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      contacts[id]['phone'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildNavigator(icon: Icons.edit, title: "Edit Contact"),
                    // buildNavigator(icon: Icons.delete, title: "Delete", index: 2),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNavigator({required IconData icon, required String title}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            _showEditPopup();
          },
          child: Icon(
             icon,
            size: 25,
            color: Colors.black,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
              color: Colors.black,
              fontSize: 14
          ),
        )
      ],
    );
  }

  void _showEditPopup() {

    setState(() {
      nameController.text = contacts[id]['name'];
      phoneNumberController.text = contacts[id]['phone'];
    });

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
                        margin: const EdgeInsets.only(top:2),
                        child: TextFormField(
                          controller: nameController,
                          onTap: (){
                            setState((){
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
                      isNameEmpty ? const Text(
                        'Name Can\'t be empty',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                        ),
                      ) : const SizedBox(),
                      Container(
                        margin: const EdgeInsets.only(top:15,),
                        child: const Text("Phone"),
                      ),
                      Container(
                        width: 260,
                        height: 40,
                        margin: const EdgeInsets.only(top:2, bottom: 5),
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
                          onTap: (){
                            setState((){
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
                      isPhoneEmpty ? const Text(
                        'Phone Can\'t be empty',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                        ),
                      ) : const SizedBox(),
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
                    height: 40.0,
                    margin: const EdgeInsets.only(left: 0),
                    child: ElevatedButton(
                      onPressed: loadingBtn ? null : () {
                        setState((){
                          if(nameController.text == ''){
                            isNameEmpty = true;
                          }else{
                            isNameEmpty = false;
                          }
                          if(phoneNumberController.text == ''){
                            isPhoneEmpty = true;
                          }else{
                            isPhoneEmpty = false;
                          }
                        });

                        if(!isNameEmpty && !isPhoneEmpty){
                          updateContact();
                          loadingBtn = false;
                          Navigator.pop(context);
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                      ),
                      child: Visibility(
                        visible: !loadingBtn,
                        replacement: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        child: const Text(
                          'Update',
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
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.red
                      ),
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

}
