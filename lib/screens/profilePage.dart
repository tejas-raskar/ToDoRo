import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo/main.dart';
import 'package:todo/screens/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final profileImageUrl = user?.userMetadata?['avatar_url'];
    final name = user?.userMetadata?['full_name'];
    final email = user?.userMetadata?['email'];
    return Scaffold(
      body: CustomScrollView(
        slivers:  [
          const SliverAppBar.large(
            title: Text(
              "Profile",
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  children: [
                    ClipOval(
                      child: Image.network(
                        profileImageUrl,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '$name',
                        style: const TextStyle(
                          fontSize: 30.0,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text('$email'),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () async {
                            await supabase.auth.signOut();
                            if (context.mounted) {
                              var box = Hive.box('tasks');
                              box.delete('tasks');
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              );
                            }
                          },
                          child: const Text('Sign Out')),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
