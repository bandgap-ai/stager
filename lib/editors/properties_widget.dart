import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stager_platform/site_state.dart';
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
  final SiteState siteState;

  /// Creates a properties widget.
  const PropertiesWidget({super.key, required this.siteState});

  @override
  State<StatefulWidget> createState() => _PropertiesWidgetState();
}

class _PropertiesWidgetState extends State<PropertiesWidget>
    with TickerProviderStateMixin {

  /// Animation controller for the bottom sheet
  AnimationController? _bottomSheetAnimationController;

  /// Current selected view in the segmented button
  String _selectedView = 'properties';

  @override
  void initState() {
    super.initState();
    _bottomSheetAnimationController = BottomSheet.createAnimationController(this);
  }

  @override
  void dispose() {
    _bottomSheetAnimationController?.dispose();
    super.dispose();
  }

  /// Opens the image picker to select an image from the gallery and adds it
  /// to the selected node's properties.
  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    final selectedNode = widget.siteState.selectedNode;

    if (pickedFile != null) {
      if (selectedNode != null) {
        final currentImagePaths = (selectedNode.properties.getProperty('imagePaths') as List<String>?) ?? [];
        selectedNode.properties.setProperty('imagePaths', [...currentImagePaths, pickedFile.path]);
        widget.siteState.notify();
      }
    }
  }

  /// Builds the content widget based on the selected view
  Widget _buildSelectedView(LeafNode selectedNode) {
    switch (_selectedView) {
      case 'properties':
        return _buildPropertiesView(selectedNode);
      case 'summary':
        return _buildSummaryView(selectedNode);
      case 'images':
        return _buildImagesView(selectedNode);
      default:
        return _buildPropertiesView(selectedNode);
    }
  }

  /// Builds the properties view
  Widget _buildPropertiesView(LeafNode selectedNode) {
    return SingleChildScrollView(
      child: NodePropertiesView(state: selectedNode),
    );
  }

  /// Builds the summary view
  Widget _buildSummaryView(LeafNode selectedNode) {
    if (selectedNode is TreeNode) {
      return SingleChildScrollView(
        child: NodeSummaryView(summary: selectedNode.summarize()),
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
  Widget _buildImagesView(LeafNode selectedNode) {
    final imagePaths = (selectedNode.properties.getProperty('imagePaths') as List<String>?) ?? [];
    
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                      child: Image.asset(
                        imagePaths[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedNode = widget.siteState.selectedNode;

    // If no node is selected, show nothing.
    if (selectedNode == null) {
      return const SizedBox.shrink();
    }

    // When a node is selected, display its properties in a bottom sheet.
    return BottomSheet(
      onClosing: () { Navigator.of(context).pop();  },
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
              // Segmented Button for view selection
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
              const SizedBox(height: 16.0),
              // Content area based on selected view
              Expanded(
                child: _buildSelectedView(selectedNode),
              ),
            ],
          ),
        );
      },
    );
  }
}
