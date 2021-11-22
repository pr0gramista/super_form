## 0.1.8
* Add `modified` getter to SuperForm
* Add `enabled` property to SuperForm, which allows to disable all form fields
* Updated Survey demo with navigation alert and SuperForm 'enabled' property
* Bugfix: SuperForm will not update descendent fields when its property is changed but have no effect
* BREAKING CHANGE (minor): SuperForm TextField and DropdownField will not longer respect InputDecoration enabled property

## 0.1.7
* Add support for disabled state via `enabled` property for SuperFormFields
* Fix ValidationError extending Dart Error class
* Set field as touched after focus is lost

## 0.1.6
* Add support for state restoration of primitives and collections of primitives
* Bump dependencies and fix deprecated usages

## 0.1.5
* Fix bug where text field would automatically set value to empty string triggering validation
* Implement toString for rules and better debug properties
* Add hint in the missing SuperForm ancestor message

## 0.1.4
* More examples with Sliders, Checkboxes, dynamic rules and dynamic fields - now also with tests
* Fix bug where field with rules would reset with an old value
* Fix bug where field with rules would throw null check error if it was just moved in the tree
* Fix bug where field would validate with old rules
* Add SuperForm.ofFieldValue

## 0.1.3
* DropdownSuperFormField
* CheckboxSuperFormField with listTile builder
* RadioSuperFormField with listTile builder
* ContainsRule
* Maximum and MinimumLengthRule now supports collections

## 0.1.2
* Fixes issue where field would not update after widgets `name` was changed
* SliderSuperFormField
* Added debug properties

## 0.1.1
* Fixed and improved README - added sections about initial values and error messages
* Better package description

## 0.1.0
Initial beta release
* TextSuperFormField
* SuperFormErrorText
* SuperForm
* SuperFormField
* Rules: IsEqual, Pattern, Email, Required, Custom, MinimumLength, MaximumLength, MinValue, MaxValue, IsNumber, IsInteger