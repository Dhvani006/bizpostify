import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'model/CompanyInfo.dart';
class EditingPage extends StatefulWidget {

  final Map<String, bool> selectedFields;
  final CompanyInfo companyInfo;

  const EditingPage({
    required this.selectedFields,
    required this.companyInfo,  // Pass the CompanyInfo here
  });

  @override
  _EditingPageState createState() => _EditingPageState();
}

class _EditingPageState extends State<EditingPage> {

  final ScreenshotController _screenshotController = ScreenshotController();
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

  List<String> _fontFamilies = ['Roboto', 'Montserrat', 'Lobster', 'Pacifico'];
  double _frameThickness = 4;
  bool _showFrame = true;
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
  double _frameWidth = 250;  // Adjust frame width and height as per your needs
  double _frameHeight = 100;
  double _mobileFontSize = 16;
  double _addressFontSize = 16;
  double _facebookFontSize = 16;
  double _linkedinFontSize = 16;
  double _twitterFontSize = 16;
  double _instagramFontSize = 16;

  bool _isDragging = false;
  String? _draggingElement;
  Offset _initialFocalPoint = Offset.zero;
  Offset _initialOffset = Offset.zero;
  double _initialSize = 1.0;
  double _initialFontSize = 1.0;

  File? _pickedPhoto;
  String? _selectedElement;

  List<String> _frames = [];
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

    _fetchFrames();
  }

  Future<void> _fetchFrames() async {
    try {
      final uri = "http://172.27.229.66/practice_api/viewFrame.php";
      final res = await http.get(Uri.parse(uri));
      if (res.statusCode == 200) {
        List<dynamic> data = jsonDecode(res.body);
        setState(() {
          _frames = data.map((item) => item['img'] as String).toList();
        });
      } else {
        print("Failed to load frames");
      }
    } catch (e) {
      print("Error fetching frames: $e");
    }
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

  bool _isOverDustbin(Offset position) {
    final RenderBox box = _canvasKey.currentContext?.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(position);

    const double dustbinSize = 60;
    final double dustbinY = box.size.height - dustbinSize - 20;
    final Rect dustbinRect = Rect.fromCenter(
      center: Offset(box.size.width / 2, dustbinY + dustbinSize / 2),
      width: dustbinSize,
      height: dustbinSize,
    );

    return dustbinRect.contains(localPosition);
  }

  void _handleDragEnd(Offset position) {
    if (_isOverDustbin(position)) {
      setState(() {
        if (_draggingElement == 'logo') _showLogo = false;
        if (_draggingElement == 'name') _showName = false;
        if (_draggingElement == 'email') _showEmail = false;
      });
    }
    setState(() {
      _isDragging = false;
      _draggingElement = null;
    });
  }

  Future<void> _saveImage() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      final image = await _screenshotController.capture();
      if (image != null) {
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/edited_image.png').create();
        await file.writeAsBytes(image);
        await GallerySaver.saveImage(file.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Image saved to gallery')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Failed to capture image')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Storage permission denied')),
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
                        case 'name': _showName = false; break;
                        case 'email': _showEmail = false; break;
                        case 'mobile': _showMobile = false; break;
                        case 'address': _showAddress = false; break;
                        case 'facebook': _showFacebook = false; break;
                        case 'linkedin': _showLinkedin = false; break;
                        case 'twitter': _showTwitter = false; break;
                        case 'instagram': _showInstagram = false; break;
                        case 'logo': _showLogo = false; break;
                        case 'frame': _showFrame = false; break;
                      }
                      _selectedElement = null;
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
                  child: Icon(Icons.zoom_out_map, color: Colors.white, size: 16),
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
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout()).size;



    return Stack(
      children: [
        Positioned(
          left: offset.dx,
          top: offset.dy,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedElement = identifier; // This will set the selected element
              });
            },
            onScaleStart: (details) {
              _initialFocalPoint = details.focalPoint;
              _initialOffset = offset;
              _initialFontSize = fontSize;
              _draggingElement = identifier; // Start dragging the selected element
            },
            onScaleUpdate: (details) {
              setState(() {
                // Update position as user scales
                onUpdateOffset(_initialOffset + (details.focalPoint - _initialFocalPoint));

                // Dynamically adjust the font size during scaling
                fontSize = _initialFontSize * details.scale; // Adjust font size based on scaling
                fontSize = fontSize.clamp(10.0, 60.0); // Limit font size within a range
              });
            },
            onLongPressStart: (details) {
              setState(() {
                _isDragging = true;
                _draggingElement = identifier;
                _initialOffset = offset;
                _initialFocalPoint = details.globalPosition;
              });
            },
            onLongPressMoveUpdate: (details) {
              setState(() {
                // Update position as user moves on long press
                onUpdateOffset(_initialOffset + (details.globalPosition - _initialFocalPoint));
              });
            },
            onLongPressEnd: (details) => _handleDragEnd(details.globalPosition),
            child: Text(
              label,
              style: TextStyle(
                color: getTextColor(identifier), // Use the dynamic color based on identifier
                fontSize: fontSize,
                fontFamily: getFontFamily(identifier), // Use the dynamic font family based on identifier
              ),
            ),
          ),
        ),
        if (_selectedElement == identifier)
          _buildSelectionBox(offset, textSize, identifier), // Show selection box if this element is selected
      ],
    );




  }


  void _selectTextColor(String identifier) async {
    final pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick a color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: getTextColor(identifier), // Use the getTextColor function to get the current color
            onColorChanged: (color) => Navigator.of(context).pop(color),
          ),
        ),
      ),
    );

    if (pickedColor != null) {
      setState(() {
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


  Widget _buildDraggableFrame() {
    final Size frameSize = Size(_frameWidth, _frameHeight);
    bool _isSelected = false;
    return Stack(
      children: [
        Positioned(
          left: _frameOffset.dx,
          top: _frameOffset.dy,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedElement = 'frame';
                _isSelected = true;
              });
            },
            onScaleStart: (details) {
              _initialFocalPoint = details.focalPoint;
              _initialOffset = _frameOffset;
              _draggingElement = 'frame';
            },
            onScaleUpdate: (details) {
              setState(() {
                _frameOffset = _initialOffset + (details.focalPoint - _initialFocalPoint);
              });
            },
            onLongPressStart: (details) {
              setState(() {
                _isDragging = true;
                _draggingElement = 'frame';
                _initialOffset = _frameOffset;
                _initialFocalPoint = details.globalPosition;
              });
            },
            onLongPressMoveUpdate: (details) {
              setState(() {
                _frameOffset = _initialOffset + (details.globalPosition - _initialFocalPoint);
              });
            },
            onLongPressEnd: (details) => _handleDragEnd(details.globalPosition),
            child: Stack(
              children: [
                Container(
                  width: _frameWidth,
                  height: _frameHeight,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:  _isSelected ? Colors.red : Colors.transparent,
                      width: 5.0,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(_selectedFrameUrl!), // Assuming _frameImageUrl is not null
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Resizing handle
                if (_selectedElement == 'frame')
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _frameWidth += details.delta.dx;
                          _frameHeight += details.delta.dy;

                          // Limit size
                          _frameWidth = _frameWidth.clamp(50.0, 500.0);
                          _frameHeight = _frameHeight.clamp(50.0, 500.0);
                        });
                      },
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.zoom_out_map, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                // Close (delete) button
                if (_selectedElement == 'frame')
                  Positioned(
                    left: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showFrame = false;
                          _selectedElement = null;
                        });
                      },
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
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
              _initialSize = _logoSize;
              _draggingElement = 'logo';
            },
            onScaleUpdate: (details) {
              setState(() {
                _logoOffset = _initialOffset + (details.focalPoint - _initialFocalPoint);
              });
            },
            onLongPressStart: (details) {
              setState(() {
                _isDragging = true;
                _draggingElement = 'logo';
                _initialOffset = _logoOffset;
                _initialFocalPoint = details.globalPosition;
              });
            },
            onLongPressMoveUpdate: (details) {
              setState(() {
                _logoOffset = _initialOffset + (details.globalPosition - _initialFocalPoint);
              });
            },
            onLongPressEnd: (details) => _handleDragEnd(details.globalPosition),
            child: Image.file(widget.companyInfo.logoPath, height: _logoSize),
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
              child: Screenshot(
                controller: _screenshotController,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      _selectedElement = null;
                    });
                  },
                  child: Container(
                    key: _canvasKey,
                    width: screenWidth * 0.95,
                    height: screenWidth * 1.2,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Stack(
                      children: [
                        // Display selected photo if one is picked
                        if (_pickedPhoto != null)
                          Positioned.fill(child: Image.file(_pickedPhoto!, fit: BoxFit.cover)),

                        // // Display the selected frame over the photo
                        // if (_selectedFrameUrl != null)
                        //   Positioned.fill(
                        //     child: Image.network(
                        //       _selectedFrameUrl!,
                        //       // Frame adjusts to fill the container
                        //     ),
                        //   ),

                        if (_selectedFrameUrl != null)
                          _buildDraggableFrame(),

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

                        if(_showMobile)
                          _buildDraggableText(
                            label: widget.companyInfo.mobile,
                            offset: _mobileOffset,
                            fontSize: _mobileFontSize,
                            onUpdateOffset: (val) => _mobileOffset = val,
                            onUpdateFontSize: (val) => _mobileFontSize = val,
                            identifier: 'mobile',
                          ),

                        if(_showAddress)
                          _buildDraggableText(
                            label: widget.companyInfo.address,
                            offset: _addressOffset,
                            fontSize: _addressFontSize,
                            onUpdateOffset: (val) => _addressOffset = val,
                            onUpdateFontSize: (val) => _addressFontSize = val,
                            identifier: 'address',
                          ),

                        if(_showFacebook)
                          _buildDraggableText(
                            label: widget.companyInfo.facebook,
                            offset: _facebookOffset,
                            fontSize: _facebookFontSize,
                            onUpdateOffset: (val) => _facebookOffset = val,
                            onUpdateFontSize: (val) => _facebookFontSize = val,
                            identifier: 'facebook',
                          ),

                        if(_showLinkedin)
                          _buildDraggableText(
                            label: widget.companyInfo.linkedin,
                            offset: _linkedinOffset,
                            fontSize: _linkedinFontSize,
                            onUpdateOffset: (val) => _linkedinOffset = val,
                            onUpdateFontSize: (val) => _linkedinFontSize = val,
                            identifier: 'linkedin',
                          ),

                        if(_showTwitter)
                          _buildDraggableText(
                            label: widget.companyInfo.twitter,
                            offset: _twitterOffset,
                            fontSize: _twitterFontSize,
                            onUpdateOffset: (val) => _twitterOffset = val,
                            onUpdateFontSize: (val) => _twitterFontSize = val,
                            identifier: 'twitter',
                          ),

                        if(_showInstagram)
                          _buildDraggableText(
                            label: widget.companyInfo.instagram,
                            offset: _instagramOffset,
                            fontSize: _instagramFontSize,
                            onUpdateOffset: (val) => _instagramOffset = val,
                            onUpdateFontSize: (val) => _instagramFontSize = val,
                            identifier: 'instagram',
                          ),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomButton('Add photo', _pickPhoto),
                _buildBottomButton('Frame', _selectFrame),
                _buildBottomButton('Text Color', () {
                  _selectTextColor(_selectedElement!); // Update the color for the selected element
                }),

                _buildBottomButton('Text Font', _selectTextFont),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _selectFrame() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _frames.length,
            itemBuilder: (context, index) {
             final String frameUrl = "http://172.27.229.66/practice_api/Frame_images/${_frames[index]}";
            //  final String frameUrl = "http://192.168.12.101/practice_api/Frame_images/servixo_logo.jpeg";
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFrameUrl = frameUrl; // Set the selected frame
                  });
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox( // 👈 added SizedBox
                    width: 200,     // 👈 set width small
                    height: 150,    //  set height small
                    child: Image.network(
                      frameUrl,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
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