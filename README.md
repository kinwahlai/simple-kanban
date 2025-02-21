# Simple Kanban

A simple, customizable Kanban board widget for Flutter applications.

## Features

- Three columns with equal widths and height that expands to the container
- Headers and footers that stick to the top and bottom
- Header with text labels
- Footer with plus icon and text field for adding new items
- Items displayed as cards with title and subtitle
- Rounded corner card style with thin border line and shadow
- Customizable background colors with proper contrast
- Drag and drop functionality for rearranging items
- Column limits to control maximum items per column
- Validation when moving items between columns

## Getting Started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  simple_kanban: ^0.1.0
```

## Usage

```dart
import 'package:simple_kanban/simple_kanban.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: KanbanBoard(),
      ),
    );
  }
}
```

## Example

Check out the [example](example) directory for a complete sample application using the Simple Kanban widget.

To run the example:

1. Clone this repository
2. Navigate to the example directory
3. Run `flutter pub get`
4. Run `flutter run`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
