import 'dart:async';

import 'package:flutter/material.dart';
import 'package:statscov/models/country.dart';
import 'package:statscov/utils/constants.dart';

typedef IsoCallback = void Function(String);

class CountriesField extends StatefulWidget {
  CountriesField(
    this.countries, {
    this.onChanged,
    this.startingText,
    this.onLoseFocus,
    this.focusNotifier,
  });
  final List<Country> countries;
  final IsoCallback onChanged;
  final String startingText;
  final Function onLoseFocus;
  final Stream focusNotifier;

  @override
  _CountriesFieldState createState() => _CountriesFieldState();
}

class _CountriesFieldState extends State<CountriesField> {
  final FocusNode _focusNode = FocusNode();
  OverlayEntry _overlayEntry;

  final LayerLink _layerLink = LayerLink();

  TextEditingController _controller = TextEditingController();
  List<Country> _filtered;

  StreamController<String> _inputStreamController;
  Stream<String> _inputStream;

  Function _focusListener;
  bool _isFocused = false;

  BorderRadius _borderRadius;
  Color _color;

  @override
  void initState() {
    super.initState();

    _focusListener = () {
      if (_focusNode.hasFocus) {
        setState(() {
          _color = AppConstants.of(context).kPrimaryTwo;
          _borderRadius = BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          );
        });
        if (_overlayEntry == null) {
          _overlayEntry = _createOverlayEntry();
        }
        if (!_isFocused) {
          _controller.text = '';
          _isFocused = true;
        }
        Overlay.of(context).insert(_overlayEntry);
      } else {
        widget.onLoseFocus();
        setState(() {
          _color = AppConstants.of(context).kPrimaryOne;
          _borderRadius = BorderRadius.circular(10.0);
        });
        _overlayEntry.remove();
      }

      widget.focusNotifier.listen((signal) {
        if (_focusNode.hasFocus) _focusNode.unfocus();
      });
    };

    _focusNode.addListener(_focusListener);

    _filtered = widget.countries;

    _inputStreamController = StreamController();
    _inputStream = _inputStreamController.stream;

    _inputStream.listen((input) {
      if (input == '') {
        _filtered = widget.countries;
      } else {
        _filtered = widget.countries.where((country) {
          return country.countryName
              .toLowerCase()
              .startsWith(input.toLowerCase());
        }).toList();
      }
      _focusNode.unfocus();
      _overlayEntry.remove();
      _focusNode.requestFocus();
    });
    _controller.text = widget.startingText;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 1.0),
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: BoxDecoration(
                    color: AppConstants.of(context).kPrimaryTwo,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          _filtered[index].countryName,
                          textAlign: TextAlign.start,
                        ),
                        onTap: () {
                          _isFocused = false;
                          _focusNode.unfocus();
                          _controller.text = _filtered[index].countryName;
                          widget.onChanged(_filtered[index].isoCode);
                          _filtered = widget.countries;
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Theme(
          data: Theme.of(context).copyWith(
            accentColor: Colors.grey.shade600,
          ),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: _color ?? AppConstants.of(context).kPrimaryOne,
              borderRadius: _borderRadius ?? BorderRadius.circular(10.0),
              border: Border.all(color: AppConstants.of(context).kDarkTertiary),
            ),
            child: TextFormField(
              focusNode: _focusNode,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 10.0,
                ),
                labelText: 'Country',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
              controller: _controller,
              onChanged: (input) {
                _inputStreamController.add(input);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _focusNode.dispose();
    if (_overlayEntry != null) _overlayEntry.remove();
    _inputStreamController.close();
  }
}
