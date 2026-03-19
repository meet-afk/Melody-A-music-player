import 'dart:io';
import 'package:client/features/auth/view/pages/login_page.dart';

import 'package:client/core/provider/current_song_notifier.dart';
import 'package:client/core/provider/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String? profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  // Load the saved profile image path from local phone storage
  Future<void> _loadProfileImage() async {
    final userId = ref.read(currentUserProvider)?.id ?? 'default';
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      profileImagePath = prefs.getString('profile_image_$userId');
    });
  }

  // Pick an image from gallery, copy it to app's secure documents, and save path
  Future<void> _pickProfileImage() async {
    final userId = ref.read(currentUserProvider)?.id ?? 'default';
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    
    if (result != null && result.files.isNotEmpty) {
      final selectedPath = result.files.first.path;
      
      if (selectedPath != null) {
        // Find the safe app document directory
        final docDir = await getApplicationDocumentsDirectory();
        
        // Generate a unique file name using timestamp AND userId
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'profile_${userId}_$timestamp.jpg';
        
        // Copy the chosen image into our app's permanent folder
        final savedFile = await File(selectedPath).copy('${docDir.path}/$fileName');
        
        // Save this new path string securely JUST FOR THIS USER
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_$userId', savedFile.path);
        
        setState(() {
          profileImagePath = savedFile.path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(homeViewmodelProvider); // Bind explicitly to react to deletions!
    
    // Get current user details
    final currentUser = ref.watch(currentUserProvider);
    // Fetch recently played songs directly from local storage
    final recentlyPlayedSongs = ref.watch(homeLocalRepositoryProvider).loadSongs();
    final currentSong = ref.watch(currentSongProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: currentSong == null ? null : BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: [
            hexToColor(currentSong.hex_code),
            Pallete.transparentColor,
          ],
          stops: [0.0, 0.7],
        ),
      ),

    child: Scaffold(
      backgroundColor: Pallete.transparentColor,
      appBar: AppBar(
        backgroundColor: Pallete.transparentColor,
        title: const Text('Profile', style: TextStyle(color: Pallete.whiteColor, fontSize: 30, fontWeight: FontWeight.bold),),
        actions: [
          IconButton(
            onPressed: () async {
              // 1. Remove the saved JWT token
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('x-auth-token');
              
              // 2. Clear the Riverpod user state
              ref.invalidate(currentUserProvider);
              
              // 3. Kick them back to the Login Page safely
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout, color: Pallete.whiteColor),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Details Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Pallete.gradient2,
                        backgroundImage: profileImagePath != null 
                            ? FileImage(File(profileImagePath!)) 
                            : null,
                        child: profileImagePath == null
                            ? Text(
                                currentUser?.name.isNotEmpty == true
                                    ? currentUser!.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Pallete.whiteColor,
                                ),
                              )
                            : null,
                      ),
                      // A little edit icon to make it obvious they can click it
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Pallete.gradient1,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 15,
                          color: Pallete.whiteColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser?.name ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Pallete.whiteColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        currentUser?.email ?? 'No email',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Pallete.subtitleText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Recently Played Section Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Text(
              'Recently Played',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Pallete.whiteColor,
              ),
            ),
          ),
          
          // Recently Played List
          Expanded(
            child: recentlyPlayedSongs.isEmpty
                ? const Center(
                    child: Text(
                      'No recently played songs.',
                      style: TextStyle(color: Pallete.subtitleText),
                    ),
                  )
                : ListView.builder(
                    itemCount: recentlyPlayedSongs.length,
                    itemBuilder: (context, index) {
                      final song = recentlyPlayedSongs[index];
                      // Displaying in the exact same format as Library page
                      return ListTile(
                        onTap: () {
                          ref.read(currentSongProvider.notifier).updadeSong(song, queue: recentlyPlayedSongs);
                        },
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(song.thumbnail_url),
                          radius: 35,
                          backgroundColor: Pallete.backgroundColor,
                        ),
                        title: Text(
                          song.song_name,
                          style: const TextStyle(
                            color: Pallete.whiteColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          song.artist,
                          style: const TextStyle(color: Pallete.subtitleText),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    ),
    );
  }
}
