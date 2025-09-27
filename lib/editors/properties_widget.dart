import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stager_platform/editors/selection.dart';
import 'package:stager_platform/editors/selection_observer.dart';
import 'package:stager_platform/editors/stager_pin.dart';
import 'package:stager_platform/editors/stager_tree_viewers.dart';
import 'package:stager_platform/tree/tree_node.dart';
import 'package:stager_platform/tree/leaf_node.dart';
import 'package:stager_platform/editors/node_properties_view.dart';

/// A widget that displays the properties of the currently selected node in a
/// bottom sheet.
///
/// This widget observes the [SiteState] and shows details about the
/// [siteState.selectedNode]. It provides functionality to view node properties
/// and to add images to the node.
class PropertiesWidget extends StatefulWidget {
  /// The state manager for the site data.
  final Selection<LeafNode> selectedNode;

  /// An optional StagerPin widget to pin the navigator.
  final StagerPin? pin;

  /// Creates a properties widget.
  ///
  /// [selectedNode]: The currently selected node.
  /// [pin]: An optional StagerPin widget to pin the properties view.
  const PropertiesWidget({super.key, required this.selectedNode, this.pin});

  @override
  State<StatefulWidget> createState() => _PropertiesWidgetState();
}

class _PropertiesWidgetState extends State<PropertiesWidget>
    with TickerProviderStateMixin
    implements SelectionObserver<LeafNode> {
  // TickerProviderStateMixin is used to create an animation controller.

  late Selection<LeafNode> selectedNode;
  StagerPin? _pin;

  /// Animation controller for the bottom sheet
  AnimationController? _bottomSheetAnimationController;

  /// Current selected view in the segmented button
  String _selectedView = 'properties';

  @override
  void initState() {
    super.initState();
    _bottomSheetAnimationController = BottomSheet.createAnimationController(
      this,
    );
    // Configure the selection and observe it.
    selectedNode = widget.selectedNode;
    selectedNode.attach(this);
    // Configure the pin used to pin the window
    _pin = widget.pin;
  }

  @override
  void dispose() {
    // Detach as an observer of the selection
    selectedNode.detach(this);
    // Dispose the animation controller
    _bottomSheetAnimationController?.dispose();
    super.dispose();
  }

  @override
  void update(selection) {
    // Redraw the widget when the selection changes
    setState(() {});
  }

  /// Opens the image picker to select an image from the gallery and adds it
  /// to the selected node's properties.
  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (selectedNode.value != null) {
        LeafNode node = selectedNode.value!;
        final currentImagePaths =
            (node.properties.getProperty('imagePaths') as List<String>?) ?? [];
        node.properties.setProperty('imagePaths', [
          ...currentImagePaths,
          pickedFile.path,
        ]);
      }
    }
  }

  /// Builds the content widget based on the selected view
  Widget _buildSelectedView(LeafNode node) {
    switch (_selectedView) {
      case 'properties':
        return _buildPropertiesView(node);
      case 'summary':
        return _buildSummaryView(node);
      case 'images':
        return _buildImagesView(node);
      default:
        return _buildPropertiesView(node);
    }
  }

  /// Builds the properties view
  Widget _buildPropertiesView(LeafNode node) {
    print('Building properties view for ${node.properties.getProperty('name')}');
    return SingleChildScrollView(
        child: NodePropertiesView(state: node),
    );
  }

  /// Builds the summary view
  Widget _buildSummaryView(LeafNode node) {
    if (node is TreeNode) {
      return SingleChildScrollView(
        child: NodeSummaryView(summary: node.summarize()),
      );
    } else {
      return Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Summary Not Available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Summary is only available for tree nodes with children.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  /// Builds the images view
  Widget _buildImagesView(LeafNode node) {
    final imagePaths =
        (node.properties.getProperty('imagePaths') as List<String>?) ??
        [];

    return Column(
      children: [
        // Add Image Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Add Image'),
          ),
        ),
        const SizedBox(height: 16.0),
        // Image Grid
        Expanded(
          child: imagePaths.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Images',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap "Add Image" to add photos to this node.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: imagePaths.length,
                  itemBuilder: (context, index) {
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(imagePaths[index], fit: BoxFit.cover),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Stack _buildButtonHeader(BuildContext context) {
    bool pinnable = _pin != null;

    return Stack(
      children: [
        Center(
          child: SegmentedButton<String>(
            segments: [
              const ButtonSegment<String>(
                value: 'properties',
                icon: Icon(Icons.info_outline),
              ),
              ButtonSegment<String>(
                value: 'summary',
                icon: const Icon(Icons.analytics_outlined),
                enabled: selectedNode is TreeNode,
              ),
              const ButtonSegment<String>(
                value: 'images',
                icon: Icon(Icons.image_outlined),
              ),
            ],
            selected: {_selectedView},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _selectedView = newSelection.first;
              });
            },
          ),
        ),
        if (pinnable) Align(alignment: Alignment.centerRight, child: _pin! ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // If no node is selected, show nothing.
    if (selectedNode.value == null) {
      return const SizedBox.shrink();
    }

    // When a node is selected, display its properties in a bottom sheet.
    return BottomSheet(
      onClosing: () {
        Navigator.of(context).pop();
      },
      animationController: _bottomSheetAnimationController!,
      enableDrag: true,
      showDragHandle: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 400, // Fixed height for better testing and UX
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildButtonHeader(context),
              const SizedBox(height: 16.0),
              // Content area based on selected view
              Expanded(child: _buildSelectedView(selectedNode.value!)),
            ],
          ),
        );
      },
    );
  }
}
