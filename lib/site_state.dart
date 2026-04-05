// lib/stager/site_state.dart
import 'package:stager_platform/data/basic_sample_data.dart';
import 'package:stager_platform/site_state_observer.dart';
import 'package:stager_platform/tree/node_observer.dart';
import 'package:stager_platform/tree/tree.dart';

/// Manages the application's state for a collection of sites, represented as a tree structure.
///
/// This class is the central hub for all data related to the sites, including the
/// tree data itself, the currently selected node, and the overall label for the site collection.
///
/// It implements the [ObservableSubject] interace, allowing other parts of the application
/// to subscribe to state changes. When the state is modified (e.g., a node is selected,
/// deleted, or a new site is added), it notifies all attached [SiteStateObserver]s.
class SiteState implements ObservableSubject {
  final List<NodeObserver> _observers = [];
  /// The top-level label for the site collection. Defaults to 'Sites'.
  String label = 'Sites';

  /// The root-level nodes of the site hierarchy.
  late List<TreeNode> _treeData;

  /// The currently selected node in the tree, or `null` if no node is selected.
  LeafNode? _selectedNode;

  /// Initializes the site state, loading the initial data from [fakeSites].
  SiteState() {
    _treeData = sampleSites;
  }

  /// The root-level nodes of the site hierarchy.
  List<TreeNode> get treeData => _treeData;
  /// The currently selected node in the tree, or `null` if no node is selected.
  LeafNode? get selectedNode => _selectedNode;

  /// Sets the currently selected node and notifies observers of the change.
  ///
  /// If the new [node] is the same as the currently selected one, no notification is sent.
  set selectedNode(LeafNode? node) {
    if (_selectedNode != node) {
      _selectedNode = node;
      notify();
    }
  }

  /// Deletes a [node] from the tree.
  ///
  /// This method handles deleting both child nodes and top-level site nodes.
  /// If the deleted node was the currently selected one, the selection is cleared.
  /// After deletion, it notifies all observers.
  void deleteNode(LeafNode node) {
    if (node.parent != null && node.parent!.isComposite) {
      (node.parent! as CompositeNode).removeChild(node);
    } else {
      // Handle deletion of a top-level site node.
      _treeData.remove(node);
    }

    // If the deleted node was the selected one, clear the selection.
    if (_selectedNode == node) {
      _selectedNode = null;
    }

    // Notify listeners of the structural change and potential selection change.
    notify();
  }

  /// Adds a new top-level site to the collection and returns a reference to it.
  ///
  /// A new [ConcreteTreeNode] is created with the given [name] and added to the
  /// [treeData]. All observers are then notified of the change.
  TreeNode addSite(String name) {
    final newSite = ConcreteTreeNode(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    _treeData.add(newSite);
    notify();

    return newSite;
  }

  /// Adds a list of nodes to the tree.
  ///
  /// Only [TreeNode] instances are added to the root of the tree data.
  /// Notifies observers after adding the nodes.
  void addNodes(List<LeafNode> nodes) {
    for (final node in nodes) {
      if (node is TreeNode) {
        _treeData.add(node);
      }
    }
    notify();
  }

  @override
  void attach(NodeObserver observer) {
    _observers.add(observer);
  }

  @override
  void detach(NodeObserver observer) {
    _observers.remove(observer);
  }

  @override
  void notify() {
    for (final observer in _observers) {
      observer.update(this);
    }
  }
}