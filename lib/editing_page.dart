import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'api_config.dart';
import 'model/CompanyInfo.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uuid/uuid.dart';

class EditingPage extends StatefulWidget {
  final Map<String, bool> selectedFields;
  final CompanyInfo companyInfo;

  const EditingPage({
    required this.selectedFields,
    required this.companyInfo, // Pass the CompanyInfo here
  });

  @override
  _EditingPageState createState() => _EditingPageState();
}

List<TextBox> _textBoxes = [];

class TextBox {
  final String identifier; // add this

  Offset offset;
  double width;
  double height;
  String text;
  double fontSize;
  String fontFamily;
  Color color;
  bool isBold;
  bool isItalic;

  TextBox({
    required this.identifier, // add this to constructor
    required this.offset,
    required this.width,
    required this.height,
    required this.text,
    required this.fontSize,
    required this.fontFamily,
    required this.color,
    required this.isBold,
    required this.isItalic,
  });
}

int? _selectedTextBoxIndex;

class _EditingPageState extends State<EditingPage> {
  String _getCompanyInfoValue(String key) {
    switch (key.toLowerCase()) {
      case 'companyname':
        return widget.companyInfo.name;
      case 'email':
        return widget.companyInfo.email;
      case 'mobile':
        return widget.companyInfo.mobile;
      case 'address':
        return widget.companyInfo.address;
      case 'facebook':
        return widget.companyInfo.facebook;
      case 'linkedin':
        return widget.companyInfo.linkedin;
      case 'twitter':
        return widget.companyInfo.twitter;
      case 'instagram':
        return widget.companyInfo.instagram;
      default:
        return key; // fallback to the original key (useful for static texts)
    }
  }

  List<Map<String, dynamic>> _frames = [];
  List<dynamic> _selectedFrameElements = [];
  final uuid = Uuid();
  void _addTextBox() {
    setState(() {
      _textBoxes.add(TextBox(
        identifier: uuid.v4(), // generate unique id here
        text: 'New Text',
        offset: Offset(100, 100),
        fontSize: 20,
        width: 150,
        height: 50,
        fontFamily: 'Arial',
        color: Colors.white,
        isBold: false,
        isItalic: false,
      ));
      _selectedTextBoxIndex = _textBoxes.length - 1;
      _selectedElement = 'textBox';
    });
  }

  bool _showFrame = true;

  bool _isResizing = false;

  Map<String, bool> _isBoldMap = {
    'name': false,
    'email': false,
    'mobile': false,
    'address': false,
    'facebook': false,
    'linkedin': false,
    'twitter': false,
    'instagram': false,
  };

  Map<String, bool> _isItalicMap = {
    'name': false,
    'email': false,
    'mobile': false,
    'address': false,
    'facebook': false,
    'linkedin': false,
    'twitter': false,
    'instagram': false,
  };

  bool _showSocialIcons = true;
  String _iconShape = 'Normal';
  String _iconPosition = 'Right';

  List<String> _selectedSocialIcons = [
    'Facebook',
    'Instagram',
    'LinkedIn',
    'Twitter',
    'YouTube'
  ];
  List<String> _selectedIcons = [];

  bool _isNameBold = false;
  bool _isEmailBold = false;
  bool _isMobileBold = false;
  bool _isAddressBold = false;
  bool _isFacebookBold = false;
  bool _isLinkedinBold = false;
  bool _isTwitterBold = false;
  bool _isInstagramBold = false;

  bool _isNameItalic = false;
  bool _isEmailItalic = false;
  bool _isMobileItalic = false;
  bool _isAddressItalic = false;
  bool _isFacebookItalic = false;
  bool _isLinkedinItalic = false;
  bool _isTwitterItalic = false;
  bool _isInstagramItalic = false;

  bool _isSelected = false;
  final GlobalKey _canvasKey = GlobalKey();
  Color _nameColor = Colors.white;
  Color _emailColor = Colors.white;
  Color _mobileColor = Colors.white;
  Color _addressColor = Colors.white;
  Color _facebookColor = Colors.white;
  Color _linkedinColor = Colors.white;
  Color _twitterColor = Colors.white;
  Color _instagramColor = Colors.white;
  String _nameFontFamily = 'Roboto';
  String _emailFontFamily = 'Roboto';
  String _mobileFontFamily = 'Roboto';
  String _addressFontFamily = 'Roboto';
  String _facebookFontFamily = 'Roboto';
  String _linkedinFontFamily = 'Roboto';
  String _twitterFontFamily = 'Roboto';
  String _instagramFontFamily = 'Roboto';

  List<String> _fontFamilies = [
    'Roboto',
    'Montserrat',
    'Lobster',
    'Pacifico',
    'Raleway',
    'DancingScript',
    'PlayfairDisplay',
    'Oswald',
    'Merriweather',
    'BebasNeue',
    'IndieFlower',
    'Quicksand',
    'Nunito',
    'Caveat',
    'Satisfy',
    'AmaticSC',
    'GreatVibes',
    'ShadowsIntoLight',
    'ArchitectsDaughter',
    'Handlee'
  ];
  double _frameThickness = 4;
  Offset _logoOffset = Offset(50, 50);
  Offset _nameOffset = Offset(50, 200);
  Offset _emailOffset = Offset(50, 250);
  Offset _mobileOffset = Offset(100, 200);
  Offset _addressOffset = Offset(100, 250);
  Offset _facebookOffset = Offset(100, 300);
  Offset _linkedinOffset = Offset(100, 350);
  Offset _twitterOffset = Offset(100, 400);
  Offset _instagramOffset = Offset(100, 450);
  double _logoSize = 80;
  double _nameFontSize = 18;
  double _emailFontSize = 14;
  Offset _frameOffset = Offset(50, 50);
  double _frameWidth = 250; // Adjust frame width and height as per your needs
  double _frameHeight = 100;
  double _mobileFontSize = 16;
  double _addressFontSize = 16;
  double _facebookFontSize = 16;
  double _linkedinFontSize = 16;
  double _twitterFontSize = 16;
  double _instagramFontSize = 16;

  Offset _initialFocalPoint = Offset.zero;
  Offset _initialOffset = Offset.zero;
  double _initialFontSize = 1.0;

  File? _pickedPhoto;
  String? _selectedElement;

  String? _selectedFrameUrl;

  bool _showName = false;
  bool _showEmail = false;
  bool _showMobile = false;
  bool _showAddress = false;
  bool _showFacebook = false;
  bool _showLinkedin = false;
  bool _showTwitter = false;
  bool _showInstagram = false;
  bool _showLogo = false;

  bool getBold(String identifier) {
    switch (identifier) {
      case 'name':
        return _isNameBold;
      case 'email':
        return _isEmailBold;
      case 'mobile':
        return _isMobileBold;
      case 'address':
        return _isAddressBold;
      case 'facebook':
        return _isFacebookBold;
      case 'linkedin':
        return _isLinkedinBold;
      case 'twitter':
        return _isTwitterBold;
      case 'instagram':
        return _isInstagramBold;
      default:
        return false;
    }
  }

  bool getItalic(String identifier) {
    switch (identifier) {
      case 'name':
        return _isNameItalic;
      case 'email':
        return _isEmailItalic;
      case 'mobile':
        return _isMobileItalic;
      case 'address':
        return _isAddressItalic;
      case 'facebook':
        return _isFacebookItalic;
      case 'linkedin':
        return _isLinkedinItalic;
      case 'twitter':
        return _isTwitterItalic;
      case 'instagram':
        return _isInstagramItalic;
      default:
        return false;
    }
  }

  @override
  void initState() {
    super.initState();

    _showName = widget.selectedFields['name'] == true;
    _showEmail = widget.selectedFields['email'] == true;
    _showMobile = widget.selectedFields['mobile'] == true;
    _showAddress = widget.selectedFields['address'] == true;
    _showFacebook = widget.selectedFields['facebook'] == true;
    _showLinkedin = widget.selectedFields['linkedin'] == true;
    _showTwitter = widget.selectedFields['twitter'] == true;
    _showInstagram = widget.selectedFields['instagram'] == true;
    _showLogo = widget.selectedFields['logo'] == true;
  }

  void _selectFrame() async {
    await _fetchAllFrames(); // Load frames from API first

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _frames.length,
            itemBuilder: (context, index) {
              final frame = _frames[index];
              final String frameUrl =
                  "$baseUrl/practice_api/Frame_images/${frame['img']}";

              return GestureDetector(
                onTap: () async {
                  final frameIdString = frame['id'];
                  print(frameIdString);

                  if (frameIdString == null) {
                    print("Frame ID is missing!");
                    return;
                  }

                  // Convert string to int
                  final frameId = int.tryParse(frameIdString);

                  if (frameId == null) {
                    print("Frame ID is not a valid integer!");
                    return;
                  }

                  // Now you can use frameId as an int
                  print("Frame ID as int: $frameId");

                  final frameDetails = await _fetchFrameDetails(frameId);

                  setState(() {
                    _selectedFrameUrl = frameUrl;
                    _selectedFrameElements = frameDetails['elements'];
                  });

                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: 200,
                    height: 150,
                    child: Image.network(frameUrl),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchFrameDetails(int frameId) async {
    final uri = "$baseUrl/practice_api/viewFrame.php?id=$frameId";
    final res = await http.get(Uri.parse(uri));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load frame details');
    }
  }

  Future<void> _fetchAllFrames() async {
    final uri = "$baseUrl/practice_api/getAllFrames.php";
    final res = await http.get(Uri.parse(uri));
    if (res.statusCode == 200) {
      final List<Map<String, dynamic>> frameList =
          List<Map<String, dynamic>>.from(jsonDecode(res.body));
      setState(() {
        _frames = frameList;
      });
    } else {
      throw Exception("Failed to load frames");
    }
  }

  void _editTextDialog(int index) {
    final controller = TextEditingController(text: _textBoxes[index].text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Text'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new text'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _textBoxes[index].text = controller.text;
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedPhoto = File(image.path);
      });
    }
  }

  void _toggleBold(String identifier) {
    setState(() {
      if (identifier == 'textBox') {
        _textBoxes[_selectedTextBoxIndex!].isBold =
            !_textBoxes[_selectedTextBoxIndex!].isBold;
      } else {
        _isBoldMap[identifier] = !_isBoldMap[identifier]!;
      }
    });
  }

  void _toggleItalic(String identifier) {
    setState(() {
      if (identifier == 'textBox') {
        _textBoxes[_selectedTextBoxIndex!].isItalic =
            !_textBoxes[_selectedTextBoxIndex!].isItalic;
      } else {
        _isItalicMap[identifier] = !_isItalicMap[identifier]!;
      }
    });
  }

  void _removeTextBox(String identifier) {
    setState(() {
      _textBoxes.removeWhere((textBox) => textBox.identifier == identifier);
    });
  }

  Future<void> _saveImage() async {
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
        return;
      }

      // Capture the widget as an image
      RenderRepaintBoundary boundary = _canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        // Save the image
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/business_card.png').create();
        await file.writeAsBytes(byteData.buffer.asUint8List());

        // Copy to downloads folder
        final downloadsDir = Directory('${tempDir.parent.path}/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        final savedFile = await file.copy(
            '${downloadsDir.path}/business_card_${DateTime.now().millisecondsSinceEpoch}.png');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Image saved to ${savedFile.path}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to save image')),
      );
    }
  }

  Widget _buildSelectionBox(Offset offset, Size size, String elementId) {
    return Positioned(
      left: offset.dx - 20,
      top: offset.dy - 20,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (_selectedElement == elementId) {
            setState(() {
              switch (elementId) {
                case 'logo':
                  _logoSize += details.delta.dx * 0.5;
                  _logoSize = _logoSize.clamp(40, 200);
                  break;
                case 'name':
                  _nameFontSize += details.delta.dx * 0.1;
                  _nameFontSize = _nameFontSize.clamp(10, 60);
                  break;
                case 'email':
                  _emailFontSize += details.delta.dx * 0.1;
                  _emailFontSize = _emailFontSize.clamp(10, 60);
                  break;
                case 'mobile':
                  _mobileFontSize += details.delta.dx * 0.1;
                  _mobileFontSize = _mobileFontSize.clamp(10, 60);
                  break;
                case 'address':
                  _addressFontSize += details.delta.dx * 0.1;
                  _addressFontSize = _addressFontSize.clamp(10, 60);
                  break;
                case 'facebook':
                  _facebookFontSize += details.delta.dx * 0.1;
                  _facebookFontSize = _facebookFontSize.clamp(10, 60);
                  break;
                case 'linkedin':
                  _linkedinFontSize += details.delta.dx * 0.1;
                  _linkedinFontSize = _linkedinFontSize.clamp(10, 60);
                  break;
                case 'twitter':
                  _twitterFontSize += details.delta.dx * 0.1;
                  _twitterFontSize = _twitterFontSize.clamp(10, 60);
                  break;
                case 'instagram':
                  _instagramFontSize += details.delta.dx * 0.1;
                  _instagramFontSize = _instagramFontSize.clamp(10, 60);
                  break;
                case 'frame':
                  _frameThickness += details.delta.dx * 0.2;
                  _frameThickness = _frameThickness.clamp(2, 20);
                  break;
              }
            });
          }
        },
        child: Container(
          width: size.width + 40,
          height: size.height + 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Delete button for each element
              Positioned(
                left: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      switch (elementId) {
                        case 'name':
                          _showName = false;
                          break;
                        case 'email':
                          _showEmail = false;
                          break;
                        case 'mobile':
                          _showMobile = false;
                          break;
                        case 'address':
                          _showAddress = false;
                          break;
                        case 'facebook':
                          _showFacebook = false;
                          break;
                        case 'linkedin':
                          _showLinkedin = false;
                          break;
                        case 'twitter':
                          _showTwitter = false;
                          break;
                        case 'instagram':
                          _showInstagram = false;
                          break;
                        case 'logo':
                          _showLogo = false;
                          break;
                        case 'frame':
                          break;
                      }
                      _selectedElement = null;
                      _isSelected = false;
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 14,
                    child: Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
              // Resize indicator
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 14,
                  child:
                      Icon(Icons.zoom_out_map, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableText({
    required String label,
    required Offset offset,
    required double fontSize,
    required Function(Offset) onUpdateOffset,
    required Function(double) onUpdateFontSize,
    required String identifier,
  }) {
    final textSize = (TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: getTextColor(identifier),
          fontSize: fontSize,
          fontFamily: getFontFamily(identifier),
          fontWeight: getBold(identifier) ? FontWeight.bold : FontWeight.normal,
          fontStyle:
              getItalic(identifier) ? FontStyle.italic : FontStyle.normal,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout())
        .size;

    return Stack(
      children: [
        Positioned(
          left: offset.dx,
          top: offset.dy,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedElement = identifier; // Select this element
              });
            },
            onPanStart: (details) {
              setState(() {
                _selectedElement = identifier;
                _initialOffset = offset;
                _initialFocalPoint = details.globalPosition;
              });
            },
            onPanUpdate: (details) {
              setState(() {
                onUpdateOffset(_initialOffset +
                    (details.globalPosition - _initialFocalPoint));
              });
            },
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: getTextColor(identifier),
                    fontSize: fontSize,
                    fontFamily: getFontFamily(identifier),
                    fontWeight: _isBoldMap[identifier]!
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontStyle: _isItalicMap[identifier]!
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
                // Show close button only if this is selected element
                if (_selectedElement == identifier)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        // Remove this text box (or element) from your list
                        _removeTextBox(identifier);
                        // Clear selection if needed
                        if (_selectedElement == identifier)
                          _selectedElement = null;
                      });
                    },
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, size: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_selectedElement == identifier)
          _buildSelectionBox(
              offset, textSize, identifier), // Existing selection box
      ],
    );
  }

  Widget _buildDraggableTextBox(int index) {
    final box = _textBoxes[index];
    final isSelected =
        _selectedElement == 'textBox' && _selectedTextBoxIndex == index;

    return Positioned(
      left: box.offset.dx,
      top: box.offset.dy,
      child: Listener(
        onPointerDown: (_) {
          setState(() {
            _selectedElement = 'textBox';
            _selectedTextBoxIndex = index;
          });
        },
        child: GestureDetector(
          onPanStart: (details) {
            if (!_isResizing) {
              setState(() {
                _initialOffset = box.offset;
                _initialFocalPoint = details.globalPosition;
              });
            }
          },
          onPanUpdate: (details) {
            if (!_isResizing) {
              setState(() {
                box.offset = _initialOffset +
                    (details.globalPosition - _initialFocalPoint);
              });
            }
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Text Box
              // Text Box with tap to edit
              GestureDetector(
                onTap: () => _editTextDialog(index),
                child: Container(
                  width: box.width,
                  height: box.height,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: isSelected
                        ? Border.all(color: Colors.blueAccent)
                        : null,
                    color: Colors.transparent,
                  ),
                  child: Text(
                    box.text,
                    maxLines: null,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontSize: box.fontSize,
                      fontFamily: box.fontFamily,
                      color: box.color,
                      fontWeight:
                          box.isBold ? FontWeight.bold : FontWeight.normal,
                      fontStyle:
                          box.isItalic ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
              ),

              if (isSelected)
                Positioned(
                  top: -10,
                  right: -10,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _textBoxes.removeAt(index);
                        _selectedTextBoxIndex = null;
                        _selectedElement = null;
                      });
                    },
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              // Resize Handle
              if (isSelected)
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (_) {
                      setState(() => _isResizing = true);
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        box.width += details.delta.dx;
                        box.height += details.delta.dy;
                        box.width = box.width.clamp(50.0, 500.0);
                        box.height = box.height.clamp(50.0, 500.0);
                      });
                    },
                    onPanEnd: (_) {
                      setState(() => _isResizing = false);
                    },
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.zoom_out_map,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSocialSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              // Wrapping with scroll view
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Social Icon Settings",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Text("Show Icons: "),
                        Switch(
                          value: _showSocialIcons,
                          onChanged: (val) {
                            setModalState(() => _showSocialIcons = val);
                            setState(() => _showSocialIcons = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text("Icon Shape"),
                    Wrap(
                      spacing: 10,
                      children:
                          ['Normal', 'Circle', 'Round Border'].map((shape) {
                        return ChoiceChip(
                          label: Text(shape),
                          selected: _iconShape == shape,
                          onSelected: (selected) {
                            setModalState(() => _iconShape = shape);
                            setState(() => _iconShape = shape);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text("Icon Position"),
                    Wrap(
                      spacing: 10,
                      children: [
                        'Left',
                        'Right',
                        'Top Left',
                        'Top Right',
                        'Top'
                      ].map((pos) {
                        return ChoiceChip(
                          label: Text(pos),
                          selected: _iconPosition == pos,
                          onSelected: (selected) {
                            setModalState(() => _iconPosition = pos);
                            setState(() => _iconPosition = pos);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text("Select Icons to Show"),
                    Wrap(
                      spacing: 10,
                      children: _selectedSocialIcons.map((icon) {
                        return ChoiceChip(
                          label: Text(icon),
                          selected: _selectedIcons.contains(icon),
                          onSelected: (selected) {
                            setModalState(() {
                              if (selected) {
                                _selectedIcons.add(icon);
                              } else {
                                _selectedIcons.remove(icon);
                              }
                            });
                            setState(() {
                              if (selected) {
                                _selectedIcons.add(icon);
                              } else {
                                _selectedIcons.remove(icon);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _selectTextColor(String identifier) async {
    final pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick a color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: identifier == 'textBox'
                ? _textBoxes[_selectedTextBoxIndex!].color
                : getTextColor(identifier),
            onColorChanged: (color) => Navigator.of(context).pop(color),
          ),
        ),
      ),
    );

    if (pickedColor != null) {
      setState(() {
        if (identifier == 'textBox') {
          _textBoxes[_selectedTextBoxIndex!].color = pickedColor;
        } else {
          // Update the appropriate color variable based on the identifier
          switch (identifier) {
            case 'name':
              _nameColor = pickedColor;
              break;
            case 'email':
              _emailColor = pickedColor;
              break;
            case 'mobile':
              _mobileColor = pickedColor;
              break;
            case 'address':
              _addressColor = pickedColor;
              break;
            case 'facebook':
              _facebookColor = pickedColor;
              break;
            case 'linkedin':
              _linkedinColor = pickedColor;
              break;
            case 'twitter':
              _twitterColor = pickedColor;
              break;
            case 'instagram':
              _instagramColor = pickedColor;
              break;
          }
        }
      });
    }
  }

  Color getTextColor(String identifier) {
    switch (identifier) {
      case 'name':
        return _nameColor;
      case 'email':
        return _emailColor;
      case 'mobile':
        return _mobileColor;
      case 'address':
        return _addressColor;
      case 'facebook':
        return _facebookColor;
      case 'linkedin':
        return _linkedinColor;
      case 'twitter':
        return _twitterColor;
      case 'instagram':
        return _instagramColor;
      default:
        return Colors.black;
    }
  }

  String getFontFamily(String identifier) {
    switch (identifier) {
      case 'name':
        return _nameFontFamily;
      case 'email':
        return _emailFontFamily;
      case 'mobile':
        return _mobileFontFamily;
      case 'address':
        return _addressFontFamily;
      case 'facebook':
        return _facebookFontFamily;
      case 'linkedin':
        return _linkedinFontFamily;
      case 'twitter':
        return _twitterFontFamily;
      case 'instagram':
        return _instagramFontFamily;

      default:
        return 'Roboto';
    }
  }

  void _selectTextFont() {
    if (_selectedElement != null) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: _fontFamilies.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _fontFamilies[index],
                    style: TextStyle(fontFamily: _fontFamilies[index]),
                  ),
                  onTap: () {
                    setState(() {
                      if (_selectedElement == 'textBox' &&
                          _selectedTextBoxIndex != null) {
                        _textBoxes[_selectedTextBoxIndex!].fontFamily =
                            _fontFamilies[index];
                      } else {
                        switch (_selectedElement) {
                          case 'name':
                            _nameFontFamily = _fontFamilies[index];
                            break;
                          case 'email':
                            _emailFontFamily = _fontFamilies[index];
                            break;
                          case 'mobile':
                            _mobileFontFamily = _fontFamilies[index];
                            break;
                          case 'address':
                            _addressFontFamily = _fontFamilies[index];
                            break;
                          case 'facebook':
                            _facebookFontFamily = _fontFamilies[index];
                            break;
                          case 'linkedin':
                            _linkedinFontFamily = _fontFamilies[index];
                            break;
                          case 'twitter':
                            _twitterFontFamily = _fontFamilies[index];
                            break;
                          case 'instagram':
                            _instagramFontFamily = _fontFamilies[index];
                            break;
                          default:
                            break;
                        }
                      }
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          );
        },
      );
    }
  }

  Widget _buildFrameWithElements() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final containerHeight = constraints.maxHeight;

        // Original size of the frame image
        const frameOriginalWidth = 1080;
        const frameOriginalHeight = 117;

        // Frame is fitted to screen width
        final frameDisplayWidth = containerWidth;
        final frameScale = frameDisplayWidth / frameOriginalWidth;
        final frameDisplayHeight = frameOriginalHeight * frameScale;

        return Stack(
          children: [
            // Frame image at the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Image.network(
                _selectedFrameUrl!,
                fit: BoxFit.fitWidth,
              ),
            ),

            // Elements positioned relative to the frame
            ..._selectedFrameElements.map((element) {
              final double elementX =
                  double.tryParse(element['pos_x'] ?? '0')! * frameScale;
              final double elementY =
                  double.tryParse(element['pos_y'] ?? '0')! * frameScale;
              final double fontSize =
                  double.tryParse(element['font_size'] ?? '14')! * frameScale;

              return Positioned(
                left: elementX,
                top: containerHeight - frameDisplayHeight + elementY,
                child: Text(
                  _getCompanyInfoValue(element['element_type'] ?? ''),
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Color(int.parse(
                        '0xff${element['font_color']?.substring(1)}')),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildSocialIcons() {
    List<Widget> icons = [];

    // Add the selected icons to the list
    if (_selectedIcons.contains('Facebook'))
      icons.add(_socialIcon(FontAwesomeIcons.facebook));
    if (_selectedIcons.contains('Instagram'))
      icons.add(_socialIcon(FontAwesomeIcons.instagram));
    if (_selectedIcons.contains('LinkedIn'))
      icons.add(_socialIcon(FontAwesomeIcons.linkedin));
    if (_selectedIcons.contains('Twitter'))
      icons.add(_socialIcon(FontAwesomeIcons.twitter));
    if (_selectedIcons.contains('YouTube'))
      icons.add(_socialIcon(FontAwesomeIcons.youtube));

    if (icons.isEmpty) {
      return Container(); // If no icons are selected, return an empty container
    }

    // Wrap the icons in a Row or Column based on icon position
    Widget iconRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: icons,
    );

    switch (_iconPosition) {
      case 'Left':
        return Positioned(left: 10, top: 50, child: iconRow);
      case 'Right':
        return Positioned(right: 10, top: 50, child: iconRow);
      case 'Top Left':
        return Positioned(left: 10, top: 10, child: iconRow);
      case 'Top Right':
        return Positioned(right: 10, top: 10, child: iconRow);
      case 'Top':
        return Positioned(
            top: 10,
            left: MediaQuery.of(context).size.width / 4,
            child: iconRow);
      default:
        return Positioned(right: 10, top: 50, child: iconRow);
    }
  }

  Widget _socialIcon(IconData iconData) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: _iconShape == 'Circle' ? BoxShape.circle : BoxShape.rectangle,
        // ✅ Only apply borderRadius if shape is rectangle
        borderRadius: _iconShape == 'Round Border' && _iconShape != 'Circle'
            ? BorderRadius.circular(10)
            : null,
        color: Colors.white,
      ),
      child: Icon(iconData, color: Colors.black, size: 20),
    );
  }

  Widget _buildDraggableLogo() {
    return Stack(
      children: [
        Positioned(
          left: _logoOffset.dx,
          top: _logoOffset.dy,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedElement = 'logo';
              });
            },
            onScaleStart: (details) {
              _initialFocalPoint = details.focalPoint;
              _initialOffset = _logoOffset;
            },
            onScaleUpdate: (details) {
              setState(() {
                _logoOffset =
                    _initialOffset + (details.focalPoint - _initialFocalPoint);
              });
            },
            onLongPressStart: (details) {
              setState(() {
                _initialOffset = _logoOffset;
                _initialFocalPoint = details.globalPosition;
              });
            },
            onLongPressMoveUpdate: (details) {
              setState(() {
                _logoOffset = _initialOffset +
                    (details.globalPosition - _initialFocalPoint);
              });
            },
            child: Image.file(
              File(widget.companyInfo.logoPath),
              height: _logoSize,
            ),
          ),
        ),
        if (_selectedElement == 'logo')
          _buildSelectionBox(_logoOffset, Size(_logoSize, _logoSize), 'logo'),
      ],
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Image'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveImage),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _canvasKey,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      _selectedElement = null;
                    });
                  },
                  child: Container(
                    width: screenWidth * 0.95,
                    height: screenWidth * 1,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Stack(
                      children: [
                        // Background image (optional)
                        // if (_selectedBackgroundImage != null)
                        //   Positioned.fill(
                        //     child: Image.asset(
                        //       _selectedBackgroundImage!,
                        //       fit: BoxFit.cover,
                        //     ),
                        //   ),

                        // Display selected photo if one is picked
                        if (_pickedPhoto != null)
                          Positioned.fill(
                              child:
                                  Image.file(_pickedPhoto!, fit: BoxFit.cover)),

                        // // Display the selected frame over the photo
                        // if (_selectedFrameUrl != null)
                        //   Positioned.fill(
                        //     child: Image.network(
                        //       _selectedFrameUrl!,
                        //       // Frame adjusts to fill the container
                        //     ),
                        //   ),

                        if (_selectedFrameUrl != null)
                          _buildFrameWithElements(),

                        // Display the logo if enabled
                        if (_showLogo) _buildDraggableLogo(),

                        // Display the company name if enabled
                        if (_showName)
                          _buildDraggableText(
                            label: widget.companyInfo.name,
                            offset: _nameOffset,
                            fontSize: _nameFontSize,
                            onUpdateOffset: (val) => _nameOffset = val,
                            onUpdateFontSize: (val) => _nameFontSize = val,
                            identifier: 'name',
                          ),

                        // Display the email if enabled
                        if (_showEmail)
                          _buildDraggableText(
                            label: widget.companyInfo.email,
                            offset: _emailOffset,
                            fontSize: _emailFontSize,
                            onUpdateOffset: (val) => _emailOffset = val,
                            onUpdateFontSize: (val) => _emailFontSize = val,
                            identifier: 'email',
                          ),

                        if (_showMobile)
                          _buildDraggableText(
                            label: widget.companyInfo.mobile,
                            offset: _mobileOffset,
                            fontSize: _mobileFontSize,
                            onUpdateOffset: (val) => _mobileOffset = val,
                            onUpdateFontSize: (val) => _mobileFontSize = val,
                            identifier: 'mobile',
                          ),

                        if (_showAddress)
                          _buildDraggableText(
                            label: widget.companyInfo.address,
                            offset: _addressOffset,
                            fontSize: _addressFontSize,
                            onUpdateOffset: (val) => _addressOffset = val,
                            onUpdateFontSize: (val) => _addressFontSize = val,
                            identifier: 'address',
                          ),

                        if (_showFacebook)
                          _buildDraggableText(
                            label: widget.companyInfo.facebook,
                            offset: _facebookOffset,
                            fontSize: _facebookFontSize,
                            onUpdateOffset: (val) => _facebookOffset = val,
                            onUpdateFontSize: (val) => _facebookFontSize = val,
                            identifier: 'facebook',
                          ),

                        if (_showLinkedin)
                          _buildDraggableText(
                            label: widget.companyInfo.linkedin,
                            offset: _linkedinOffset,
                            fontSize: _linkedinFontSize,
                            onUpdateOffset: (val) => _linkedinOffset = val,
                            onUpdateFontSize: (val) => _linkedinFontSize = val,
                            identifier: 'linkedin',
                          ),

                        if (_showTwitter)
                          _buildDraggableText(
                            label: widget.companyInfo.twitter,
                            offset: _twitterOffset,
                            fontSize: _twitterFontSize,
                            onUpdateOffset: (val) => _twitterOffset = val,
                            onUpdateFontSize: (val) => _twitterFontSize = val,
                            identifier: 'twitter',
                          ),

                        if (_showInstagram)
                          _buildDraggableText(
                            label: widget.companyInfo.instagram,
                            offset: _instagramOffset,
                            fontSize: _instagramFontSize,
                            onUpdateOffset: (val) => _instagramOffset = val,
                            onUpdateFontSize: (val) => _instagramFontSize = val,
                            identifier: 'instagram',
                          ),

                        // ..._stickers.map((sticker) {
                        //   return Positioned(
                        //     left: sticker.position.dx,
                        //     top: sticker.position.dy,
                        //     child: GestureDetector(
                        //       onPanUpdate: (details) {
                        //         setState(() {
                        //           sticker.position += details.delta;
                        //         });
                        //       },
                        //       child: Stack(
                        //         alignment: Alignment.topRight,
                        //         children: [
                        //           Image.asset(
                        //             sticker.assetPath,
                        //             width: 80,
                        //             height: 80,
                        //             fit: BoxFit.contain,
                        //           ),
                        //           GestureDetector(
                        //             onTap: () {
                        //               setState(() {
                        //                 _stickers.remove(sticker);
                        //               });
                        //             },
                        //             child: CircleAvatar(
                        //               radius: 10,
                        //               backgroundColor: Colors.red,
                        //               child: Icon(Icons.close, size: 12, color: Colors.white),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   );
                        // }).toList(),

                        for (int i = 0; i < _textBoxes.length; i++)
                          _buildDraggableTextBox(i),

                        if (_showSocialIcons) _buildSocialIcons(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bottom buttons for actions like selecting photo, frame, etc.
          Container(
            color: const Color(0xFFb6ae77),
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              // Added scroll in case buttons overflow
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomButton('Add photo', _pickPhoto),
                  _buildBottomButton('Frame', _selectFrame),
                  _buildBottomButton('Text Color', () {
                    if (_selectedTextBoxIndex != null) {
                      _selectTextColor('textBox');
                    } else if (_selectedElement != null) {
                      _selectTextColor(_selectedElement!);
                    }
                  }),

                  _buildBottomButton('Text Font', _selectTextFont),
                  _buildBottomButton('Bold', () {
                    if (_selectedTextBoxIndex != null) {
                      _toggleBold('textBox');
                    } else if (_selectedElement != null) {
                      _toggleBold(_selectedElement!);
                    }
                  }),

                  _buildBottomButton('Italic', () {
                    if (_selectedTextBoxIndex != null) {
                      _toggleItalic('textBox');
                    } else if (_selectedElement != null) {
                      _toggleItalic(_selectedElement!);
                    }
                  }),

                  _buildBottomButton('TextBox', _addTextBox),

                  _buildBottomButton('Social', _showSocialSettings),

                  // _buildBottomButton('Background', _selectBackgroundImage),
                  //
                  // _buildBottomButton('Sticker', _showStickerPicker),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFb6ae77),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        elevation: 2,
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}
