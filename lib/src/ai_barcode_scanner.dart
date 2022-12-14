import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'enums/validate_type.dart';
import 'overlay.dart';

/// Barcode scanner widget
class AiBarcodeScanner extends StatefulWidget {
  /// Function that gets Called when barcode is scanned successfully
  final void Function(String) onScan;

  /// Function that gets called when a Barcode is detected.
  ///
  /// [barcode] The barcode object with all information about the scanned code.
  /// [args] Information about the state of the MobileScanner widget
  final Function(Barcode barcode) onDetect;

  /// Validate barcode text with [ValidateType]
  /// [validateText] and [validateType] must be set together.
  final String? validateText;

  /// Validate type [ValidateType]
  /// Validator working with single string value only.
  final ValidateType? validateType;

  /// Set to false if you don't want duplicate barcode to be detected
  final bool allowDuplicates;

  /// Fit to screen
  final BoxFit fit;

  /// Barcode controller (optional)
  final MobileScannerController? controller;

  /// Show overlay or not (default: true)
  final bool showOverlay;

  /// Overlay border color (default: white)
  final Color borderColor;

  /// Overlay border width (default: 10)
  final double borderWidth;

  /// Overlay color
  final Color overlayColor;

  /// Overlay border radius (default: 10)
  final double borderRadius;

  /// Overlay border length (default: 30)
  final double borderLength;

  /// Overlay cut out width (optional)
  final double? cutOutWidth;

  /// Overlay cut out height (optional)
  final double? cutOutHeight;

  /// Overlay cut out offset (default: 0)
  final double cutOutBottomOffset;

  /// Overlay cut out size (default: 300)
  final double cutOutSize;

  /// Show hint or not (default: true)
  final bool showHint;

  /// Hint text (default: 'Scan QR Code')
  final String hintText;

  /// Hint margin
  final EdgeInsetsGeometry hintMargin;

  /// Hint padding
  final EdgeInsetsGeometry hintPadding;

  /// Hint background color (optional)
  final Color? hintBackgroundColor;

  /// Hint text style
  final TextStyle hintTextStyle;

  /// Show error or not (default: true)
  final bool showError;

  /// Error color (default: red)
  final Color errorColor;

  /// Error text (default: 'Invalid BarCode')
  final String errorText;

  /// Show success or not (default: true)
  final bool showSuccess;

  /// Success color (default: green)
  final Color successColor;

  /// Success text (default: 'BarCode Found')
  final String successText;

  /// Can auto back to previous page when barcode is successfully scanned (default: true)
  final bool canPop;

  final bool autoResume;

  final dynamic Function(bool)? onPermissionSet;

  const AiBarcodeScanner({
    Key? key,
    required this.onScan,
    this.validateText,
    this.validateType,
    this.allowDuplicates = false,
    this.fit = BoxFit.cover,
    this.controller,
    required this.onDetect,
    this.borderColor = Colors.white,
    this.borderWidth = 10,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 10,
    this.borderLength = 40,
    this.cutOutSize = 300,
    this.cutOutWidth,
    this.cutOutHeight,
    this.cutOutBottomOffset = 0,
    this.showHint = true,
    this.hintText = 'Scan QR Code',
    this.hintMargin = const EdgeInsets.all(16),
    this.hintBackgroundColor,
    this.hintTextStyle = const TextStyle(fontWeight: FontWeight.bold),
    this.hintPadding = const EdgeInsets.all(0),
    this.showOverlay = true,
    this.showError = true,
    this.errorColor = Colors.red,
    this.errorText = 'Invalid BarCode',
    this.showSuccess = true,
    this.successColor = Colors.green,
    this.successText = 'BarCode Found',
    this.canPop = true,
    this.autoResume = true,
    this.onPermissionSet,
  })  : assert(validateText == null || validateType != null),
        assert(validateText != null || validateType == null),
        super(key: key);

  @override
  State<AiBarcodeScanner> createState() => _AiBarcodeScannerState();
}

class _AiBarcodeScannerState extends State<AiBarcodeScanner> {
  /// bool to check if barcode is valid or not
  bool? _isSuccess;

  /// Scanner controller

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: 200,
      height: 200,
    );
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: widget.controller,
            fit: widget.fit,
            key: widget.key,
            scanWindow: scanWindow,
            onDetect: (barcode) {
              widget.onDetect.call(barcode.barcodes.first);
              if (barcode.barcodes.first.rawValue?.isEmpty ?? true) {
                debugPrint('Failed to scan Barcode');
                return;
              }
              if (widget.validateText?.isNotEmpty ?? false) {
                if (!widget.validateType!.toValidateTypeBool(
                    barcode.barcodes.first.rawValue!, widget.validateText!)) {
                  if (!widget.allowDuplicates) {
                    HapticFeedback.vibrate();
                  }
                  final String code = barcode.barcodes.first.rawValue!;
                  debugPrint('Invalid Barcode => $code');
                  _isSuccess = false;
                  setState(() {});
                  return;
                }
              }
              _isSuccess = true;
              if (!widget.allowDuplicates) {
                HapticFeedback.mediumImpact();
              }
              final String code = barcode.barcodes.first.rawValue!;
              debugPrint('Barcode rawValue => $code');
              widget.onScan(code);
              setState(() {});
              if (widget.canPop && mounted) {
                Navigator.pop(context);
              }
            },
          ),
          if (widget.showOverlay)
            Container(
              decoration: ShapeDecoration(
                shape: OverlayShape(
                  borderRadius: widget.borderRadius,
                  borderColor: ((_isSuccess ?? false) && widget.showSuccess)
                      ? widget.successColor
                      : (!(_isSuccess ?? true) && widget.showError)
                          ? widget.errorColor
                          : widget.borderColor,
                  borderLength: widget.borderLength,
                  borderWidth: widget.borderWidth,
                  cutOutSize: widget.cutOutSize,
                  cutOutBottomOffset: widget.cutOutBottomOffset,
                  cutOutWidth: widget.cutOutWidth,
                  cutOutHeight: widget.cutOutHeight,
                  overlayColor: widget.overlayColor,
                ),
              ),
            ),
          if (widget.showHint)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Card(
                  color: widget.hintBackgroundColor,
                  margin: widget.hintMargin,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                  child: ListTile(
                    contentPadding: widget.hintPadding,
                    leading: IconButton(
                      color: Theme.of(context).primaryColor,
                      tooltip: "Switch Camera",
                      onPressed: () => widget.controller!.switchCamera(),
                      icon: ValueListenableBuilder<CameraFacing>(
                        valueListenable: widget.controller!.cameraFacingState,
                        builder: (context, state, child) {
                          switch (state) {
                            case CameraFacing.front:
                              return const Icon(Icons.camera_front);
                            case CameraFacing.back:
                              return const Icon(Icons.camera_rear);
                          }
                        },
                      ),
                    ),
                    title: Text(
                      widget.hintText,
                      textAlign: TextAlign.center,
                      style: widget.hintTextStyle,
                    ),
                    trailing: IconButton(
                      tooltip: "Torch",
                      onPressed: () => widget.controller!.toggleTorch(),
                      icon: ValueListenableBuilder<TorchState>(
                        valueListenable: widget.controller!.torchState,
                        builder: (context, state, child) {
                          switch (state) {
                            case TorchState.off:
                              return const Icon(
                                Icons.flash_off,
                                color: Colors.grey,
                              );
                            case TorchState.on:
                              return const Icon(
                                Icons.flash_on,
                                color: Colors.orange,
                              );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
