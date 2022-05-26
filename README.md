# custom_crop

This is an image editor that provides x-axis, y-axis, z-axis rotation offset, overall 90-degree rotation, flip up and down, flip left and right, support multi-finger zoom function. Since it's written entirely in dart, it doesn't depend on any mobile packages. Therefore, it can run on all platforms supported by flutter: mobile, web and desktop, etc.

![Screenshot](https://github.com/ShiDiZhiNeng/image_crop/blob/master/example/assets/sample.png "Screenshot")

Some initial configurable parameters before creating the edit box.

```dart
final editorConfig = DataEditorConfig(
	// Configure the padding of the editing area
    cropRectPadding: const EdgeInsets.all(20.0),

    // Configure the length of the four corners of the viewfinder
    cornerLength: 30,

    // Configure the width of the four corners of the viewfinder
    cornerWidth: 4,

    // Configure the color of the four corners of the viewfinder
    cornerColor: Colors.blue,

    // Configure the click response area of the four corners of the viewfinder
    cornerHitTestSize: const Size(40, 40),

    // Configure the color of the four sides of the viewfinder
    lineColor: Colors.white,

    // Configure the color of the four sides of the viewfinder
    lineWidth: 2,

    // Configure the width of the four sides of the viewfinder frame
    lineHitTestWidth: 40,

    // Configure the length of each unit of the nine-square dotted line in the viewfinder
    dottedLength: 2,

    // Configure the color of the dotted line of the nine-square grid in the viewfinder
    dottedColor: Colors.white,

    // Configure the color of the outer portion of the viewfinder
    editorMaskColorHandler: (context, isTouching) {
      return Colors.black;
    });
```

Use a controller to manipulate the editing graph.

```dart
final controller = ImageEditorController();

	// x-axis rotation angle reduction
	controller.reduceRotateXAngle();

	// x-axis rotation angle increased
	controller.addRotateXAngle();

	// The y-axis rotation angle decreases
	controller.reduceRotateYAngle();

	// The y-axis rotation angle increases
	controller.addRotateYAngle();

	// The z-axis rotation angle increases
	controller.addRotateAngle();

	// The z-axis rotation angle is reduced
	controller.reduceRotateAngle();

	// 90 degree rotation angle increase
	controller.addRotateAngle90();

	// 90 degree rotation angle reduction
	controller.reduceRotateAngle90();

	// scaling down
	controller.reduceScaleRatio();

	// Zoom ratio increased
	controller.addScaleRatio();

	// upside down
	controller.upsideDown();

	// Flip left and right
	controller.turnAround();

	// confirm crop
	controller.tailor();

	// restore the original state
	controller.restore();

```

How to create an edit box

```dart
Expanded(
  child: ImageEditorPlane(
      imageData: imageData,
      controller: controller,
      editorConfig: editorConfig),
),

```
