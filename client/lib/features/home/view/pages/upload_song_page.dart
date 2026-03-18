import 'dart:io';
import 'package:client/core/custom_field.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/wigets/loader.dart';
import 'package:client/features/home/view/widgets/audio_border.dart';
import 'package:client/features/home/view/widgets/audio_wave.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadSongPage extends ConsumerStatefulWidget {
  const UploadSongPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UploadSongPageState();
}

class _UploadSongPageState extends ConsumerState<UploadSongPage> {
  final songNameController = TextEditingController();
  final artistNameController = TextEditingController();
  Color selectedColor = Pallete.cardColor;
  File? selectedAudio;
  File? selectedImage;
  final formKey = GlobalKey<FormState>();

  void selectAudio() async {
    final pickedAudio = await pickAudio();
    if (pickedAudio != null) {
      setState(() {
        selectedAudio = pickedAudio;
      });
    }
  }

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        selectedImage = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      homeViewmodelProvider.select((val) => val?.isLoading == true),
    );
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Upload Song", style: GoogleFonts.mulish(fontSize: 20)),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              if (formKey.currentState!.validate() &&
                  selectedAudio != null &&
                  selectedImage != null) {
                ref
                    .read(homeViewmodelProvider.notifier)
                    .uploadSong(
                      selectedAudio: selectedAudio!,
                      selectedThumbnail: selectedImage!,
                      songNAme: songNameController.text,
                      artist: artistNameController.text,
                      selectColor: selectedColor,
                    );
              } else {
                showSnackBar(context, "Please fill all the fields");
              }
            },
            icon: Icon(Icons.done_outline_sharp),
          ),
        ],
      ),
      body: isLoading
          ? const Loader()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: selectImage,
                        child: selectedImage != null
                            ? SizedBox(
                                height: 160,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.all(
                                    Radius.circular(10),
                                  ),
                                  child: Image.file(
                                    selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : DottedBorder(
                                options: RoundedRectDottedBorderOptions(
                                  radius: Radius.circular(10),
                                  color: Pallete.borderColor,
                                  dashPattern: [10, 5],
                                ),
                                child: SizedBox(
                                  height: 160,
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.upload, size: 40),
                                      SizedBox(height: 15),
                                      Text(
                                        "select the thumbnail for your song",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 40),
                      selectedAudio != null
                          ? AudioBorder(
                              child: AudioWave(path: selectedAudio!.path),
                            )
                          : CustomField(
                              hintText: "Pick Song",
                              controller: null,
                              readOnly: true,
                              onTap: selectAudio,
                            ),
                      const SizedBox(height: 20),
                      CustomField(
                        hintText: "Song Name",
                        controller: songNameController,
                      ),
                      const SizedBox(height: 20),
                      CustomField(
                        hintText: "Artist Name",
                        controller: artistNameController,
                      ),
                      const SizedBox(height: 20),
                      ColorPicker(
                        pickersEnabled: const {
                          ColorPickerType.primary: true,
                          ColorPickerType.accent: true,
                          ColorPickerType.wheel: true,
                        },
                        onColorChanged: (Color color) {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        color: selectedColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
