import 'package:contact_list/contact_list.dart';
import 'package:flutter/material.dart';

class SearchContact extends SearchDelegate {
  final List<Map<String, dynamic>> contactData;

  SearchContact({required this.contactData});

// clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

// second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

// third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<Map<String, dynamic>> matchQuery2 = [];
    List<int> contactId = [];

    for (var i = 0; i < contactData.length; i++) {
      if ((contactData[i]['name'].toLowerCase().contains(query.toLowerCase())) ||
          (contactData[i]['phone'].toLowerCase().contains(query.toLowerCase()))) {
        matchQuery2.add(contactData[i]);
        contactId.add(i);
      }
    }
    return ListView.builder(
      itemCount: matchQuery2.length,
      itemBuilder: (context, index) {
        var result = matchQuery2[index];
        var id = contactId[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) {
                return ContactList(cId: id, contactData: contactData);
              },
            ));
          },
          child: ListTile(
            title: Text(result['name']),
            subtitle: Text(result['phone']),
          ),
        );
      },
    );
  }

// querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    List<Map<String, dynamic>> matchQuery2 = [];
    List<int> contactId = [];

    for (var i = 0; i < contactData.length; i++) {
      if ((contactData[i]['name'].toLowerCase().contains(query.toLowerCase())) ||
          (contactData[i]['phone'].toLowerCase().contains(query.toLowerCase()))) {
        matchQuery2.add(contactData[i]);
        contactId.add(i);
      }
    }
    return ListView.builder(
      itemCount: matchQuery2.length > 5 ? 5 : matchQuery2.length,
      itemBuilder: (context, index) {
        var result = matchQuery2[index];
        var id = contactId[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) {
                return ContactList(cId: id, contactData: contactData);
              },
            ));
          },
          child: ListTile(
            title: Text(result['name']),
            subtitle: Text(result['phone']),
          ),
        );
      },
    );
  }
}