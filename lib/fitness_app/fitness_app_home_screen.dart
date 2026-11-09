import 'package:castme/DirecterManageAuditions.dart';
import 'package:castme/DirecterManageVecancy.dart';
import 'package:castme/DirecterViewProfiles.dart';
import 'package:castme/DirectorViewBookings.dart';
import 'package:castme/DirectoraddSeminar.dart';
import 'package:castme/DirectorendComplaints.dart';
import 'package:castme/DirectorsChatBox.dart';
import 'package:castme/EventCalendarScreen.dart';
import 'package:castme/fitness_app/models/tabIcon_data.dart';
import 'package:castme/fitness_app/my_diary/my_diary_screen.dart';
import 'package:castme/login.dart';
import 'package:flutter/material.dart';
import 'bottom_navigation_view/bottom_bar_view.dart';
import 'package:castme/fitness_app/fitness_app_theme.dart';

class FitnessAppHomeScreen extends StatefulWidget {
  @override
  _FitnessAppHomeScreenState createState() => _FitnessAppHomeScreenState();
}

class _FitnessAppHomeScreenState extends State<FitnessAppHomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  Widget tabBody = Container(
    color: FitnessAppTheme.background,
  );

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);

    // Set initial screen to MyDiaryScreen (you can change this to any other screen)
    tabBody = MyDiaryScreen(animationController: animationController);
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          // title: Text('Pattissirie'),
          backgroundColor: Colors.black,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                // Open the drawer using the context
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ),
        drawer: Drawer(
          width: 180,
          child: Column(
            children: [
              Container(
                height: 93,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Center(
                    child: Text(
                      'Cast Me',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FitnessAppHomeScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.message),
                title: Text('Actors'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DirecterViewProfiles()));
                },
              ),
              ListTile(
                leading: Icon(Icons.message),
                title: Text('Work Shop'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DirectoraddSeminar()));
                },
              ),
              ListTile(
                leading: Icon(Icons.airplane_ticket),
                title: Text('Bookings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => DirectorViewBookings()));
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Vecancy'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DirecterManageVecancy()));
                },
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Audiation'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EventCalendarScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Chat'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DirectorsChatBox()));
                },
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Complaints'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DirectorendComplaints()));
                },
              ),

              ListTile(
                leading: Icon(Icons.info),
                title: Text('Sign Out'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                },
              ),
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
            tabBody,
            floatingActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget floatingActionButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 20.0, // Adjust bottom padding
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          backgroundColor: FitnessAppTheme.nearlyDarkBlue,
          onPressed: () {
            _openModal(context);
          },
          child: Icon(Icons.add, color: FitnessAppTheme.white),
        ),
      ),
    );
  }

  void _openModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: 260.0,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Add logic for Settings
                },
              ),
              ListTile(
                leading: Icon(Icons.chat),
                title: Text('Chat'),
                onTap: () {
                  Navigator.pop(context);
                  // Add logic for Chat
                },
              ),
              ListTile(
                leading: Icon(Icons.report),
                title: Text('Complaints'),
                onTap: () {
                  Navigator.pop(context);  // Close the current screen
                  // Navigate to DirectorendComplaints
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DirectorendComplaints(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Log out'),
                onTap: () {
                  Navigator.pop(context);  // Close the current screen
                  // Navigate to Login page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// Dummy Screens for Tab Navigation
class ViewVacancyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("View Vacancy Screen", style: TextStyle(fontSize: 24)),
    );
  }
}

class AuditionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Audition Screen", style: TextStyle(fontSize: 24)),
    );
  }
}
