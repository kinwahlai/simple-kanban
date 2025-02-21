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
- Customizable initial items and column limits
- Fully customizable colors through theming

## Getting Started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  simple_kanban: ^0.1.0
```

## Usage

Basic usage:

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

### Customization

The KanbanBoard widget accepts several parameters for customization:

```dart
KanbanBoard(
  // Custom initial items for each column
  initialItems: {
    'To Do': [
      KanbanItem(
        id: '1',
        title: 'Task 1',
        subtitle: 'Description',
      ),
    ],
  },
  
  // Custom limits for each column
  columnLimits: {
    'To Do': 6,
    'In Progress': 4,
    'Done': 8,
  },
  
  // Custom column titles
  columnTitles: ['Backlog', 'Doing', 'Completed'],
  
  // Custom theme
  theme: KanbanBoardTheme(
    backgroundColor: Colors.grey.shade100,
    columnColor: Colors.white,
    cardColor: Colors.blue.shade50,
    cardBorderColor: Colors.blue.shade200,
    headerColor: Colors.blue.shade500,
    footerColor: Colors.white,
  ),
)
```

### Theme Properties

The `KanbanBoardTheme` class allows you to customize the following colors:

- `backgroundColor`: The background color of the entire board
- `columnColor`: The background color of each column
- `cardColor`: The background color of the cards
- `cardBorderColor`: The border color of the cards
- `headerColor`: The background color of column headers
- `footerColor`: The background color of column footers

## Example

Check out the [example](example) directory for a complete sample application using the Simple Kanban widget.

To run the example:

1. Clone this repository
2. Navigate to the example directory
3. Run `flutter pub get`
4. Run `flutter run`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
