import 'package:stager_platform/stager.dart';
import 'package:stager_platform/system/point.dart';
import 'package:stager_platform/system/typed_value.dart';
import 'package:stager_platform/tree/node_observer.dart';
import 'package:stager_platform/tree/node_visitor.dart';
import 'package:uuid/uuid_value.dart';

/// This is a null implementation of a CompositeNode that is used as a utility
/// class in builders and other places where logically a comparison against
/// nothing can't be avoided.
final class NullComposite implements CompositeNode {

  const NullComposite();

  @override
  UuidValue get id => UuidValue.fromString("493c7cef-9bf4-4dd2-9634-bf783373eb23");

  @override
  String get name => '';

  @override
  Point get position => Point();

  @override
  set id(UuidValue newId) {
    // Do nothing
  }

  @override
  set name(String newName) {
    // Do nothing
  }

  @override
  set position(Point newPoint) {
    // Do nothing
  }

  @override
  void accept(NodeVisitor visitor) {
    // TODO: implement accept
  }

  @override
  void addChild(LeafNode child) {
    // TODO: implement addChild
  }

  @override
  void attach(NodeObserver<dynamic> observer) {
    // TODO: implement attach
  }

  @override
  // TODO: implement children
  List<LeafNode> get children => throw UnimplementedError();

  @override
  bool containsProperty(String key) {
    // TODO: implement containsProperty
    throw UnimplementedError();
  }

  @override
  void detach(NodeObserver<dynamic> observer) {
    // TODO: implement detach
  }

  @override
  void fromMap(Map<String, Object> inputMap) {
    // TODO: implement fromMap
  }

  @override
  bool hasNext() {
    // TODO: implement hasNext
    throw UnimplementedError();
  }

  @override
  bool hasParent() {
    // TODO: implement hasParent
    throw UnimplementedError();
  }

  @override
  bool hasPrevious() {
    // TODO: implement hasPrevious
    throw UnimplementedError();
  }

  @override
  // TODO: implement isComposite
  bool get isComposite => throw UnimplementedError();

  @override
  // TODO: implement next
  LeafNode get next => throw UnimplementedError();

  @override
  void notify() {
    // TODO: implement notify
  }

  @override
  // TODO: implement parent
  LeafNode get parent => throw UnimplementedError();

  @override
  // TODO: implement previous
  LeafNode get previous => throw UnimplementedError();

  @override
  String property(String key) {
    // TODO: implement property
    throw UnimplementedError();
  }

  @override
  void removeChild(LeafNode child) {
    // TODO: implement removeChild
  }

  @override
  void resetRelatives() {
    // TODO: implement resetRelatives
  }

  @override
  void setNext(LeafNode next) {
    // TODO: implement setNext
  }

  @override
  void setParent(LeafNode parent) {
    // TODO: implement setParent
  }

  @override
  void setPrevious(LeafNode previous) {
    // TODO: implement setPrevious
  }

  @override
  void setProperty(String key, TypedValue<Object> value) {
    // TODO: implement setProperty
  }

  @override
  Object toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  Map<String, Object> toMap() {
    // TODO: implement toMap
    throw UnimplementedError();
  }

  @override
  TypedValue<Object> typedProperty(String key) {
    // TODO: implement typedProperty
    throw UnimplementedError();
  }
}